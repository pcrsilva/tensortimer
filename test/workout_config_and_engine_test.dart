import 'package:flutter_test/flutter_test.dart';
import 'package:tensortimer/features/workout_config/models/cadence_info.dart';
import 'package:tensortimer/features/workout_config/models/cadence_sub_phase.dart';
import 'package:tensortimer/features/workout_config/models/exercise_config.dart';
import 'package:tensortimer/features/workout_config/models/work_mode.dart';
import 'package:tensortimer/features/workout_config/models/workout_config.dart';
import 'package:tensortimer/features/workout_config/models/workout_phase.dart';
import 'package:tensortimer/features/workout_execution/models/cadence_progress.dart';
import 'package:tensortimer/features/workout_execution/models/timer_state.dart';
import 'package:tensortimer/features/workout_execution/providers/workout_timer_engine.dart';
import 'package:tensortimer/core/utils/duration_formatter.dart';

void main() {
  group('Multi-Exercise WorkoutConfig & Duration Calculations', () {
    test('Calculates full custom routine: Supino 3030, Inclinado 2020, Crucifixo 2020, Bíceps 40s', () {
      // Treino personalizado completo:
      // 1. Supino Reto: 3030 (6s/rep) x 8 reps = 48s por série x 2 séries = 96s trab.
      //    + 1 descanso interno de 60s + 1 transição de 90s = 246s
      // 2. Supino Inclinado: 2020 (4s/rep) x 10 reps = 40s por série x 2 séries = 80s trab.
      //    + 1 descanso interno de 60s + 1 transição de 90s = 230s
      // 3. Crucifixo: 2020 (4s/rep) x 20 reps = 80s por série x 2 séries = 160s trab.
      //    + 1 descanso interno de 60s + 1 transição de 90s = 310s
      // 4. Rosca Bíceps: 40s por série x 3 séries = 120s trab.
      //    + 2 descansos internos de 45s = 90s = 210s
      // Preparação: 10s | Volta à calma: 30s
      // Total = 10 + 246 + 230 + 310 + 210 + 30 = 1036s (17:16)
      const workout = WorkoutConfig(
        id: 'user_full_chest_biceps',
        name: 'Peito & Bíceps TUT Personalizado',
        prepareSeconds: 10,
        coolDownSeconds: 30,
        exercises: [
          ExerciseConfig(
            id: 'ex_1',
            name: 'Supino Reto',
            workMode: WorkMode.cadence,
            cadenceInfo: CadenceInfo(
              eccentricSeconds: 3,
              isometric1Seconds: 0,
              concentricSeconds: 3,
              isometric2Seconds: 0,
              targetReps: 8,
            ),
            sets: 2,
            restBetweenSetsSeconds: 60,
            restAfterExerciseSeconds: 90,
          ),
          ExerciseConfig(
            id: 'ex_2',
            name: 'Supino Inclinado',
            workMode: WorkMode.cadence,
            cadenceInfo: CadenceInfo(
              eccentricSeconds: 2,
              isometric1Seconds: 0,
              concentricSeconds: 2,
              isometric2Seconds: 0,
              targetReps: 10,
            ),
            sets: 2,
            restBetweenSetsSeconds: 60,
            restAfterExerciseSeconds: 90,
          ),
          ExerciseConfig(
            id: 'ex_3',
            name: 'Crucifixo',
            workMode: WorkMode.cadence,
            cadenceInfo: CadenceInfo(
              eccentricSeconds: 2,
              isometric1Seconds: 0,
              concentricSeconds: 2,
              isometric2Seconds: 0,
              targetReps: 20,
            ),
            sets: 2,
            restBetweenSetsSeconds: 60,
            restAfterExerciseSeconds: 90,
          ),
          ExerciseConfig(
            id: 'ex_4',
            name: 'Rosca Bíceps',
            workMode: WorkMode.time,
            workSeconds: 40,
            sets: 3,
            restBetweenSetsSeconds: 45,
            restAfterExerciseSeconds: 0,
          ),
        ],
      );

      expect(workout.totalExercises, 4);
      expect(workout.totalSets, 9); // 2 + 2 + 2 + 3 = 9 séries
      expect(workout.totalDurationSeconds, 1036);
      expect(DurationFormatter.format(workout.totalDuration), '17:16');

      final timeline = workout.compileTimeline();
      // Total de passos:
      // 1 prep + (2 work + 1 rest + 1 transition) + (2 work + 1 rest + 1 transition) + (2 work + 1 rest + 1 transition) + (3 work + 2 rest) + 1 cooldown
      // = 1 + 4 + 4 + 4 + 5 + 1 = 19 passos
      expect(timeline.length, 19);
      expect(timeline.first.phase, WorkoutPhase.prepare);
      expect(timeline.last.phase, WorkoutPhase.coolDown);

      // Valida o primeiro exercício no timeline
      final supinoStep1 = timeline[1];
      expect(supinoStep1.phase, WorkoutPhase.work);
      expect(supinoStep1.exerciseName, 'Supino Reto');
      expect(supinoStep1.exerciseIndex, 1);
      expect(supinoStep1.totalExercises, 4);
      expect(supinoStep1.duration.inSeconds, 48);

      // Valida transição entre Supino e Inclinado
      final transition1 = timeline[4];
      expect(transition1.phase, WorkoutPhase.restBetweenSets);
      expect(transition1.title, 'Troca de Exercício');
      expect(transition1.description, contains('Supino Inclinado'));
      expect(transition1.duration.inSeconds, 90);

      // Valida exercício de tempo fixo (Rosca Bíceps)
      final bicepsStep = timeline.firstWhere((s) => s.exerciseName == 'Rosca Bíceps' && s.phase == WorkoutPhase.work);
      expect(bicepsStep.duration.inSeconds, 40);
      expect(bicepsStep.totalSets, 3);
    });

    test('CadenceProgress accurately tracks sub-phases (eccentric 0->E, concentric C->0)', () {
      const cadence = CadenceInfo(
        eccentricSeconds: 3,
        isometric1Seconds: 0,
        concentricSeconds: 3,
        isometric2Seconds: 0,
        targetReps: 8,
      );

      // No início da repetição 1 (t = 1.0s): deve estar na Descida (Excêntrica) mostrando 1s
      final p1 = CadenceProgress.calculate(
        cadence: cadence,
        stepElapsed: const Duration(milliseconds: 1000),
      );
      expect(p1.currentRep, 1);
      expect(p1.currentSubPhase, CadenceSubPhase.eccentric);
      expect(p1.displaySecond, 1);
      expect(p1.isCountingUp, true);

      // Na transição para a subida (t = 4.0s - 1s dentro da concêntrica):
      // Deve estar na Subida (Concêntrica) e mostrando tempo descendo (2s)
      final p2 = CadenceProgress.calculate(
        cadence: cadence,
        stepElapsed: const Duration(milliseconds: 4000),
      );
      expect(p2.currentRep, 1);
      expect(p2.currentSubPhase, CadenceSubPhase.concentric);
      expect(p2.displaySecond, 2);
      expect(p2.isCountingUp, false);

      // Na repetição 2 (t = 7.0s - 1s dentro da rep 2):
      final p3 = CadenceProgress.calculate(
        cadence: cadence,
        stepElapsed: const Duration(milliseconds: 7000),
      );
      expect(p3.currentRep, 2);
      expect(p3.currentSubPhase, CadenceSubPhase.eccentric);
      expect(p3.displaySecond, 1);
    });

    test('JSON serialization and deserialization of multi-exercise WorkoutConfig', () {
      const original = WorkoutConfig(
        id: 'cfg_multi_123',
        name: 'Treino Hipertrofia TUT',
        prepareSeconds: 15,
        coolDownSeconds: 60,
        exercises: [
          ExerciseConfig(
            id: 'ex_1',
            name: 'Supino Reto',
            workMode: WorkMode.cadence,
            cadenceInfo: CadenceInfo(
              eccentricSeconds: 4,
              isometric1Seconds: 1,
              concentricSeconds: 2,
              isometric2Seconds: 1,
              targetReps: 8,
            ),
            sets: 3,
            restBetweenSetsSeconds: 60,
            restAfterExerciseSeconds: 90,
          ),
          ExerciseConfig(
            id: 'ex_2',
            name: 'Rosca Martelo',
            workMode: WorkMode.time,
            workSeconds: 35,
            sets: 3,
            restBetweenSetsSeconds: 45,
            restAfterExerciseSeconds: 0,
          ),
        ],
      );

      final json = original.toJson();
      final restored = WorkoutConfig.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.exercises.length, 2);
      expect(restored.exercises[0].name, 'Supino Reto');
      expect(restored.exercises[0].cadenceInfo.code, '4121');
      expect(restored.exercises[0].effectiveWorkSeconds, 64); // (4+1+2+1) * 8 = 64s
      expect(restored.exercises[1].name, 'Rosca Martelo');
      expect(restored.exercises[1].workSeconds, 35);
      expect(restored.totalDurationSeconds, original.totalDurationSeconds);
    });
  });

  group('WorkoutTimerEngine Multi-Exercise Execution', () {
    test('Steps through multi-exercise timeline with transition phases', () {
      const config = WorkoutConfig(
        id: 'test_multi_engine',
        prepareSeconds: 2,
        coolDownSeconds: 0,
        exercises: [
          ExerciseConfig(
            id: 'ex_1',
            name: 'Supino',
            workMode: WorkMode.time,
            workSeconds: 3,
            sets: 2,
            restBetweenSetsSeconds: 2,
            restAfterExerciseSeconds: 4,
          ),
          ExerciseConfig(
            id: 'ex_2',
            name: 'Crucifixo',
            workMode: WorkMode.time,
            workSeconds: 3,
            sets: 1,
            restBetweenSetsSeconds: 0,
            restAfterExerciseSeconds: 0,
          ),
        ],
      );

      final timeline = config.compileTimeline();
      // Timeline:
      // Step 0: Prepare (2s)
      // Step 1: Supino Set 1 (3s)
      // Step 2: Supino Rest (2s)
      // Step 3: Supino Set 2 (3s)
      // Step 4: Transition to Crucifixo (4s)
      // Step 5: Crucifixo Set 1 (3s)
      expect(timeline.length, 6);

      final events = <TimerAudioEvent>[];
      final engine = WorkoutTimerEngine(
        timeline: timeline,
        onTimerEvent: (event, {countdownSecond, currentStep, cadenceSubPhase}) {
          events.add(event);
        },
      );

      expect(engine.state.status, WorkoutTimerStatus.idle);
      engine.start();
      expect(engine.state.status, WorkoutTimerStatus.running);
      expect(engine.state.currentStep?.phase, WorkoutPhase.prepare);

      // Pula para o Supino Set 1
      engine.skipNext();
      expect(engine.state.currentStep?.exerciseName, 'Supino');
      expect(engine.state.currentStep?.setIndex, 1);

      // Pula para o Descanso interno do Supino
      engine.skipNext();
      expect(engine.state.currentStep?.phase, WorkoutPhase.rest);

      // Pula para o Supino Set 2
      engine.skipNext();
      expect(engine.state.currentStep?.setIndex, 2);

      // Pula para a Transição de exercício
      engine.skipNext();
      expect(engine.state.currentStep?.phase, WorkoutPhase.restBetweenSets);
      expect(engine.state.currentStep?.title, 'Troca de Exercício');

      // Pula para o Crucifixo
      engine.skipNext();
      expect(engine.state.currentStep?.exerciseName, 'Crucifixo');

      // Conclui
      engine.skipNext();
      expect(engine.state.status, WorkoutTimerStatus.completed);
      expect(events.contains(TimerAudioEvent.workoutCompleted), true);

      engine.dispose();
    });
  });
}
