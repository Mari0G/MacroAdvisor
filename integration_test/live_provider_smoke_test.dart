import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live provider connection and AI meal creation', (tester) async {
    runApp(
      ProviderScope(
        overrides: productionOverrides().cast(),
        child: const MacroAdvisorApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Record meal').first);
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(
      find.byKey(const Key('meal-description-field')),
      'Greek yogurt with banana and almonds',
    );
    await tester.tap(find.byKey(const Key('analyze-meal-button')));
    for (var i = 0; i < 90 && find.text('Review estimate').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(find.text('Review estimate'), findsOneWidget);
    expect(find.text('Confirm and save'), findsOneWidget);
    expect(find.text('Gemini'), findsOneWidget);
  });
}
