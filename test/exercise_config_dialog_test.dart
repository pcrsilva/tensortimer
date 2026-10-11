import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tensortimer/features/workout_config/models/cadence_info.dart';
import 'package:tensortimer/features/workout_config/models/exercise_config.dart';
import 'package:tensortimer/features/workout_config/models/work_mode.dart';
import 'package:tensortimer/features/workout_config/presentation/widgets/exercise_config_dialog.dart';
import 'package:tensortimer/features/workout_config/presentation/widgets/exercise_list_section.dart';

void main() {
  group('ExerciseConfigDialog & ExerciseListSection Tests', () {
    testWidgets('ExerciseListSection renders exercise items and allows dialog opening',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final exercises = [
        const ExerciseConfig(
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
          sets: 3,
          restBetweenSetsSeconds: 60,
          restAfterExerciseSeconds: 90,
        ),
        const ExerciseConfig(
          id: 'ex_2',
          name: 'Agachamento',
          workMode: WorkMode.cadence,
          cadenceInfo: CadenceInfo(
            eccentricSeconds: 4,
            isometric1Seconds: 1,
            concentricSeconds: 2,
            isometric2Seconds: 0,
            targetReps: 10,
          ),
          sets: 4,
          restBetweenSetsSeconds: 90,
          restAfterExerciseSeconds: 120,
        ),
      ];

      ExerciseConfig? savedExercise;
      String? duplicatedId;
      String? deletedId;
      bool added = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExerciseListSection(
                exercises: exercises,
                onExerciseChanged: (ex) => savedExercise = ex,
                onDuplicateExercise: (id) => duplicatedId = id,
                onDeleteExercise: (id) => deletedId = id,
                onAddExercise: () => added = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica cabeçalho e contagem
      expect(find.text('EXERCÍCIOS DO TREINO'), findsOneWidget);
      expect(find.text('2 exercícios'), findsOneWidget);
      expect(find.text('Supino Reto'), findsOneWidget);
      expect(find.text('Agachamento'), findsOneWidget);

      // Clica em 'Novo'
      await tester.tap(find.text('Novo'));
      await tester.pumpAndSettle();
      expect(added, isTrue);

      // Clica no card do exercício para abrir a caixa de diálogo
      await tester.tap(find.text('Supino Reto'));
      await tester.pumpAndSettle();

      // Diálogo aberto
      expect(find.text('Configurar Exercício'), findsOneWidget);
      expect(find.text('VELOCIDADE DO MOVIMENTO (CADÊNCIA TUT)'), findsOneWidget);
      expect(find.text('SÉRIES & TEMPOS DE DESCANSO'), findsOneWidget);

      // Altera a cadência clicando no preset '4020'
      await tester.tap(find.text('4020'));
      await tester.pumpAndSettle();

      // Salva
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Confirma que o callback foi acionado com a nova cadência
      expect(savedExercise, isNotNull);
      expect(savedExercise!.cadenceInfo.code, equals('4020'));
      expect(savedExercise!.name, equals('Supino Reto'));

      // Testa botão duplicar
      await tester.tap(find.byTooltip('Duplicar Exercício').first);
      await tester.pumpAndSettle();
      expect(duplicatedId, equals('ex_1'));
    });
  });
}
