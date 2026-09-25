import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tensortimer/features/workout_config/models/cadence_info.dart';
import 'package:tensortimer/features/workout_config/models/exercise_config.dart';
import 'package:tensortimer/features/workout_config/models/work_mode.dart';
import 'package:tensortimer/features/workout_config/models/workout_config.dart';
import 'package:tensortimer/features/workout_config/presentation/screens/workout_config_screen.dart';
import 'package:tensortimer/features/workout_config/presentation/widgets/preset_selector_sheet.dart';
import 'package:tensortimer/features/workout_execution/presentation/screens/workout_execution_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'WorkoutConfigScreen displays weekday schedule bar, multi-exercise builder and allows presets/settings',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WorkoutConfigScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TensionTimer'), findsOneWidget);
    expect(find.textContaining('CRONOGRAMA SEMANAL'), findsOneWidget);

    // Abre modal de Presets
    await tester.tap(find.byIcon(Icons.bookmarks_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Rotinas & Presets'), findsOneWidget);

    // Seleciona o preset Pernas dentro do Modal Sheet
    final pernasFinder = find.descendant(
      of: find.byType(PresetSelectorSheet),
      matching: find.textContaining('Pernas Hipertrofia TUT'),
    );
    expect(pernasFinder, findsOneWidget);
    await tester.tap(pernasFinder);
    await tester.pumpAndSettle();

    // Abre configurações de Som
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Configurações do Timer'), findsOneWidget);
    expect(find.text('Avisos Sonoros (Bipes em 3, 2, 1)'), findsOneWidget);
    expect(find.text('Feedback Tátil / Vibração'), findsOneWidget);
    expect(find.text('Manter Tela Sempre Ligada'), findsOneWidget);

    await tester.tap(find.text('Concluído'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'WorkoutExecutionScreen renders multi-exercise active badges and cadence displays',
      (WidgetTester tester) async {
    const config = WorkoutConfig(
      id: 'test_multi_exec',
      name: 'Peito Hipertrofia TUT',
      prepareSeconds: 2,
      coolDownSeconds: 0,
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
          restBetweenSetsSeconds: 5,
          restAfterExerciseSeconds: 10,
        ),
        ExerciseConfig(
          id: 'ex_2',
          name: 'Rosca Bíceps',
          workMode: WorkMode.time,
          workSeconds: 40,
          sets: 3,
          restBetweenSetsSeconds: 30,
          restAfterExerciseSeconds: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WorkoutExecutionScreen(config: config),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Peito Hipertrofia TUT'), findsOneWidget);
    expect(find.text('PREPARAÇÃO'), findsOneWidget);
    expect(find.text('EXERCÍCIO 1 DE 2'), findsOneWidget);
    expect(find.text('SÉRIE 1 DE 2'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    // Pula para o bloco de Trabalho do Supino (TUT Cadence)
    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.pumpAndSettle();

    // Deve exibir o mostrador de Cadência com Sub-fase (DESCIDA), REP 1 DE 8 e nome do exercício
    expect(find.text('DESCIDA'), findsOneWidget);
    expect(find.text('REP 1 DE 8'), findsOneWidget);
    expect(find.text('Supino Reto'), findsOneWidget);
    expect(find.text('Tempo do Bloco:'), findsOneWidget);
    expect(find.textContaining('00:48'), findsOneWidget); // 6s * 8 reps = 48s

    // Pausa o timer
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pumpAndSettle();
    expect(find.text('PAUSADO'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}
