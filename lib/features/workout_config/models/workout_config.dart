import 'cadence_info.dart';
import 'exercise_config.dart';
import 'interval_step.dart';
import 'work_mode.dart';
import 'workout_phase.dart';

/// Configuração completa de um treino multi-exercício com cadência TUT ou tempo fixo
class WorkoutConfig {
  final String id;
  final String name;
  final int prepareSeconds;
  final List<ExerciseConfig> exercises;
  final int coolDownSeconds;

  const WorkoutConfig({
    required this.id,
    this.name = 'Meu Treino TUT',
    this.prepareSeconds = 10,
    this.exercises = const [
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
        name: 'Crucifixo Reto',
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
    this.coolDownSeconds = 0,
  });

  /// Total de exercícios cadastrados no treino
  int get totalExercises => exercises.length;

  /// Total de séries somando todos os exercícios
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets);

  /// Duração total calculada em segundos
  int get totalDurationSeconds {
    int total = 0;

    // 1. Preparação
    if (prepareSeconds > 0) {
      total += prepareSeconds;
    }

    // 2. Exercícios
    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      final workSec = ex.effectiveWorkSeconds;

      for (int s = 1; s <= ex.sets; s++) {
        total += workSec;

        // Descanso entre séries do mesmo exercício
        if (s < ex.sets && ex.restBetweenSetsSeconds > 0) {
          total += ex.restBetweenSetsSeconds;
        }
      }

      // Descanso / Transição para o próximo exercício (exceto após o último exercício)
      if (i < exercises.length - 1 && ex.restAfterExerciseSeconds > 0) {
        total += ex.restAfterExerciseSeconds;
      }
    }

    // 3. Volta à calma
    if (coolDownSeconds > 0) {
      total += coolDownSeconds;
    }

    return total;
  }

  /// Duração total convertida para [Duration]
  Duration get totalDuration => Duration(seconds: totalDurationSeconds);

  /// Total de blocos executáveis
  int get totalIntervals {
    int count = 0;
    if (prepareSeconds > 0) count++;

    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      for (int s = 1; s <= ex.sets; s++) {
        count++; // Work
        if (s < ex.sets && ex.restBetweenSetsSeconds > 0) {
          count++; // Rest between sets
        }
      }
      if (i < exercises.length - 1 && ex.restAfterExerciseSeconds > 0) {
        count++; // Transition to next exercise
      }
    }

    if (coolDownSeconds > 0) count++;
    return count;
  }

  /// Compila a estrutura do treino em uma lista linear ordenada de [IntervalStep]
  List<IntervalStep> compileTimeline() {
    final List<IntervalStep> timeline = [];
    int stepCounter = 0;
    final int numExercises = exercises.length;

    // 1. Fase de Preparação Inicial
    if (prepareSeconds > 0) {
      final firstExName =
          exercises.isNotEmpty ? exercises.first.name : '1º Exercício';
      timeline.add(
        IntervalStep(
          id: 'step_${++stepCounter}',
          phase: WorkoutPhase.prepare,
          duration: Duration(seconds: prepareSeconds),
          exerciseIndex: 1,
          totalExercises: numExercises > 0 ? numExercises : 1,
          exerciseName: firstExName,
          setIndex: 1,
          totalSets: exercises.isNotEmpty ? exercises.first.sets : 1,
          title: 'Preparação',
          description: 'Prepare-se para iniciar: $firstExName',
        ),
      );
    }

    // 2. Exercícios e Séries
    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      final exIndex = i + 1;
      final isCadence = ex.workMode.isCadence;
      final workSec = ex.effectiveWorkSeconds;

      for (int s = 1; s <= ex.sets; s++) {
        // Bloco de Trabalho / Tensão do Exercício
        final subDesc = isCadence
            ? '${ex.cadenceInfo.targetReps} reps @ ${ex.cadenceInfo.code} • Série $s de ${ex.sets}'
            : '${ex.workSeconds}s de execução • Série $s de ${ex.sets}';

        timeline.add(
          IntervalStep(
            id: 'step_${++stepCounter}',
            phase: WorkoutPhase.work,
            duration: Duration(seconds: workSec),
            exerciseIndex: exIndex,
            totalExercises: numExercises,
            exerciseName: ex.name,
            setIndex: s,
            totalSets: ex.sets,
            title: ex.name,
            description: subDesc,
            cadence: isCadence ? ex.cadenceInfo : null,
          ),
        );

        // Bloco de Descanso entre séries do mesmo exercício
        if (s < ex.sets && ex.restBetweenSetsSeconds > 0) {
          timeline.add(
            IntervalStep(
              id: 'step_${++stepCounter}',
              phase: WorkoutPhase.rest,
              duration: Duration(seconds: ex.restBetweenSetsSeconds),
              exerciseIndex: exIndex,
              totalExercises: numExercises,
              exerciseName: ex.name,
              setIndex: s,
              totalSets: ex.sets,
              title: 'Descanso: ${ex.name}',
              description: 'Próxima: Série ${s + 1} de ${ex.sets}',
            ),
          );
        }
      }

      // Bloco de Descanso / Transição para o próximo exercício
      if (i < exercises.length - 1 && ex.restAfterExerciseSeconds > 0) {
        final nextEx = exercises[i + 1];
        timeline.add(
          IntervalStep(
            id: 'step_${++stepCounter}',
            phase: WorkoutPhase.restBetweenSets,
            duration: Duration(seconds: ex.restAfterExerciseSeconds),
            exerciseIndex: exIndex,
            totalExercises: numExercises,
            exerciseName: ex.name,
            setIndex: ex.sets,
            totalSets: ex.sets,
            title: 'Troca de Exercício',
            description: 'Próximo: ${nextEx.name} (${nextEx.prescriptionSummary})',
          ),
        );
      }
    }

    // 3. Fase de Volta à Calma Final
    if (coolDownSeconds > 0) {
      timeline.add(
        IntervalStep(
          id: 'step_${++stepCounter}',
          phase: WorkoutPhase.coolDown,
          duration: Duration(seconds: coolDownSeconds),
          exerciseIndex: numExercises,
          totalExercises: numExercises,
          exerciseName: 'Conclusão',
          setIndex: 1,
          totalSets: 1,
          title: 'Volta à Calma',
          description: 'Alongamento e relaxamento final',
        ),
      );
    }

    return timeline;
  }

  WorkoutConfig copyWith({
    String? id,
    String? name,
    int? prepareSeconds,
    List<ExerciseConfig>? exercises,
    int? coolDownSeconds,
  }) {
    return WorkoutConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      prepareSeconds: prepareSeconds ?? this.prepareSeconds,
      exercises: exercises ?? this.exercises,
      coolDownSeconds: coolDownSeconds ?? this.coolDownSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prepareSeconds': prepareSeconds,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'coolDownSeconds': coolDownSeconds,
    };
  }

  factory WorkoutConfig.fromJson(Map<String, dynamic> json) {
    final list = json['exercises'] as List<dynamic>?;
    final exercises = list != null
        ? list.map((e) => ExerciseConfig.fromJson(e as Map<String, dynamic>)).toList()
        : const <ExerciseConfig>[];

    return WorkoutConfig(
      id: json['id'] as String? ?? 'workout_default',
      name: json['name'] as String? ?? 'Meu Treino TUT',
      prepareSeconds: json['prepareSeconds'] as int? ?? 10,
      exercises: exercises.isNotEmpty
          ? exercises
          : const WorkoutConfig(id: 'default').exercises,
      coolDownSeconds: json['coolDownSeconds'] as int? ?? 0,
    );
  }
}
