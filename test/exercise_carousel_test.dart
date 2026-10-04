import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tensortimer/features/workout_config/models/cadence_info.dart';
import 'package:tensortimer/features/workout_config/models/exercise_config.dart';
import 'package:tensortimer/features/workout_config/models/work_mode.dart';
import 'package:tensortimer/features/workout_config/presentation/widgets/exercise_carousel.dart';

Widget _createCarouselTestApp({
  required List<ExerciseConfig> exercises,
  required ValueChanged<ExerciseConfig> onChanged,
  required ValueChanged<String> onDuplicate,
  required ValueChanged<String> onDelete,
  required VoidCallback onAdd,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ExerciseCarousel(
          exercises: exercises,
          onExerciseChanged: onChanged,
          onDuplicateExercise: onDuplicate,
          onDeleteExercise: onDelete,
          onAddExercise: onAdd,
        ),
      ),
    ),
  );
}

void main() {
  group('ExerciseCarousel Widget Tests', () {
    testWidgets('Renders exercise tabs, indicators, controls and active card',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
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
            targetReps: 10,
          ),
          sets: 4,
          restBetweenSetsSeconds: 60,
          restAfterExerciseSeconds: 90,
        ),
        const ExerciseConfig(
          id: 'ex_2',
          name: 'Crucifixo',
          workMode: WorkMode.time,
          workSeconds: 45,
          sets: 3,
          restBetweenSetsSeconds: 45,
          restAfterExerciseSeconds: 0,
        ),
      ];

      var added = false;
      var duplicatedId = '';
      var deletedId = '';
      ExerciseConfig? updatedExercise;

      await tester.pumpWidget(
        _createCarouselTestApp(
          exercises: exercises,
          onChanged: (ex) => updatedExercise = ex,
          onDuplicate: (id) => duplicatedId = id,
          onDelete: (id) => deletedId = id,
          onAdd: () => added = true,
        ),
      );
      await tester.pumpAndSettle();

      // Header e Contador
      expect(find.text('EXERCÍCIOS DO TREINO'), findsOneWidget);
      expect(find.text('1 de 2'), findsOneWidget);

      // Abas dos Exercícios
      expect(find.text('Supino Reto'), findsWidgets);
      expect(find.text('Crucifixo'), findsWidgets);

      // Controles Anterior e Próximo
      expect(find.text('Anterior'), findsOneWidget);
      expect(find.text('Próximo'), findsOneWidget);

      // Navega para o Exercício 2 clicando em 'Próximo'
      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();

      expect(find.text('2 de 2'), findsOneWidget);

      // Navega de volta clicando na aba 'Supino Reto'
      await tester.tap(find.text('Supino Reto').first);
      await tester.pumpAndSettle();

      expect(find.text('1 de 2'), findsOneWidget);

      // Clica no chip 'Novo'
      await tester.tap(find.text('Novo'));
      await tester.pumpAndSettle();
      expect(added, isTrue);

      // Clica em duplicar
      await tester.tap(find.byTooltip('Duplicar Exercício'));
      await tester.pumpAndSettle();
      expect(duplicatedId, equals('ex_1'));
    });
  });
}
