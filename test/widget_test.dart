import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tensortimer/main.dart';
import 'package:tensortimer/features/workout_config/presentation/screens/workout_config_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Renders TensionTimerApp and WorkoutConfigScreen with summary and start button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TensionTimerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TensionTimer'), findsOneWidget);
    expect(find.byType(WorkoutConfigScreen), findsOneWidget);
    expect(find.text('Tempo Total'), findsOneWidget);
    expect(find.text('Exercícios'), findsOneWidget);
    expect(find.text('Séries Totais'), findsOneWidget);
    expect(find.text('INICIAR TREINO'), findsOneWidget);
    expect(find.text('Presets'), findsOneWidget);
  });
}
