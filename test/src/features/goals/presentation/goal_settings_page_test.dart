import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';
import 'package:macro_advisor/src/features/goals/presentation/goal_settings_page.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  testWidgets('configures a nutrient target and saves localized settings', (
    tester,
  ) async {
    final repository = _FakeGoalRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [goalRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GoalSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nutrition goals'), findsOneWidget);
    expect(find.text('Energy'), findsOneWidget);
    await tester.tap(find.text('Minimum').first);
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, '1800');
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-goals-button')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-goals-button')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('save-goals-button')));
    await tester.pumpAndSettle();

    expect(
      repository.saved[NutrientId.energy],
      const MinimumGoalTarget(1800000),
    );
  });

  testWidgets('invalid range remains visible and cannot be saved', (
    tester,
  ) async {
    final repository = _FakeGoalRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [goalRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GoalSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Range').first);
    await tester.pump();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '100');
    await tester.enterText(fields.at(1), '50');
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-goals-button')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('save-goals-button')));
    await tester.pump();

    expect(find.text('The minimum must not exceed the maximum.'), findsWidgets);
    expect(repository.saved, GoalSet.empty());
  });
}

class _FakeGoalRepository implements GoalRepository {
  GoalSet saved = GoalSet.empty();

  @override
  Future<GoalSet> read() async => GoalSet.empty();

  @override
  Stream<GoalSet> observe() => Stream.value(GoalSet.empty());

  @override
  Future<GoalSet> replace(GoalSet goals) async {
    saved = goals;
    return goals;
  }
}
