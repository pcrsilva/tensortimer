import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tensortimer/features/workout_config/presentation/screens/about_app_screen.dart';

Widget _createTestApp() {
  return const ProviderScope(
    child: MaterialApp(
      home: AboutAppScreen(),
    ),
  );
}

void main() {
  group('AboutAppScreen Widget Tests', () {
    testWidgets('Renders AboutAppScreen with header, categories and disclaimer',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Verifica AppBar e Header
      expect(find.text('Sobre o TensionTimer'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.text('Cadência TUT'), findsOneWidget);
      expect(find.text('Multi-Exercício'), findsOneWidget);
      expect(find.text('100% Offline'), findsOneWidget);

      // Verifica categorias principais
      expect(find.textContaining('Tempo sob Tensão'), findsWidgets);
      expect(find.textContaining('Montador Multi-Exercício'), findsWidgets);
      expect(find.textContaining('Fórmula de Cadência'), findsWidgets);

      // Testa campo de pesquisa
      await tester.enterText(find.byType(TextField), '3030');
      await tester.pumpAndSettle();

      expect(find.textContaining('Fórmula de Cadência'), findsWidgets);

      // Limpa a busca
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.textContaining('Montador Multi-Exercício'), findsWidgets);
    });

    testWidgets('Filters features by clicking category filter chips',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Clica no chip de filtro "Tempo sob Tensão (TUT)" (primeiro widget com o texto)
      final chipTextFinder = find.text('Tempo sob Tensão (TUT)').first;
      expect(chipTextFinder, findsOneWidget);

      await tester.tap(chipTextFinder);
      await tester.pumpAndSettle();

      // Apenas a categoria Tempo sob Tensão deve estar visível nas seções
      expect(find.text('Tempo sob Tensão (TUT)'), findsWidgets);
      expect(find.text('Montador Multi-Exercício'), findsOneWidget); // Somente no chip
    });
  });
}
