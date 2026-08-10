import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live provider connection and AI meal creation', (tester) async {
    runApp(
      ProviderScope(
        overrides: productionOverrides().cast(),
        child: const MacroAdvisorApp(),
      ),
    );
    await _waitFor(tester, find.byKey(const Key('today-settings-button')));
    await tester.tap(find.byKey(const Key('today-settings-button')));
    await _waitFor(tester, find.byKey(const Key('provider-settings-entry')));
    await tester.tap(find.byKey(const Key('provider-settings-entry')));
    await _waitForAny(tester, <Finder>[
      find.byKey(const Key('provider-credential-status-configured')),
      find.byKey(const Key('provider-credential-status-missing')),
    ]);
    if (find
        .byKey(const Key('provider-credential-status-missing'))
        .evaluate()
        .isNotEmpty) {
      fail(
        'Live Gemini smoke requires a credential saved through Provider settings on this emulator.',
      );
    }
    await tester.pageBack();
    await _waitFor(tester, find.byKey(const Key('provider-settings-entry')));
    await tester.pageBack();
    await _waitFor(tester, find.byKey(const Key('today-settings-button')));
    await tester.tap(find.byKey(const Key('today-record-meal-button')));
    await _waitFor(tester, find.byKey(const Key('describe-meal-source')));
    await tester.tap(find.byKey(const Key('describe-meal-source')));
    await _waitFor(tester, find.byKey(const Key('meal-description-field')));
    await tester.enterText(
      find.byKey(const Key('meal-description-field')),
      'Greek yogurt with banana and almonds',
    );
    final analyzeButton = find.byKey(const Key('analyze-meal-button'));
    await tester.ensureVisible(analyzeButton);
    await tester.tap(analyzeButton);
    await _waitFor(
      tester,
      find.byKey(const Key('review-estimate-title')),
      timeout: const Duration(seconds: 90),
    );

    expect(find.byKey(const Key('review-estimate-title')), findsOneWidget);
    expect(find.byKey(const Key('confirm-save-button')), findsOneWidget);
    expect(find.byKey(const Key('review-provenance')), findsOneWidget);
  });
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  expect(finder, findsOneWidget);
}

Future<void> _waitForAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finders.any((finder) => finder.evaluate().isNotEmpty)) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  expect(finders.first, findsOneWidget);
}
