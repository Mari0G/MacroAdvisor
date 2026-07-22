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
  testWidgets('renders localized saved targets and form controls', (
    tester,
  ) async {
    final repository = _FakeGoalRepository(
      GoalSet({NutrientId.protein: const MinimumGoalTarget(30000)}),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [goalRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GoalSettingsPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Goal settings'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    expect(find.text('Minimum (g)'), findsOneWidget);
    expect(find.byKey(const Key('save-goals-button')), findsOneWidget);
    expect(repository.saved[NutrientId.protein], isA<MinimumGoalTarget>());
  });

  testWidgets(
    'formats persisted German targets with a comma decimal separator',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            goalRepositoryProvider.overrideWithValue(
              _FakeGoalRepository(
                GoalSet({NutrientId.protein: const MinimumGoalTarget(30500)}),
              ),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('de'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: GoalSettingsPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Zieleinstellungen'), findsOneWidget);
      expect(find.text('30,5'), findsOneWidget);
      expect(find.text('Minimum (g)'), findsOneWidget);
    },
  );
}

class _FakeGoalRepository implements GoalRepository {
  _FakeGoalRepository(this.saved);

  GoalSet saved;

  @override
  Stream<GoalSet> observe() => Stream.value(saved);

  @override
  Future<void> save(GoalSet goals) async {
    saved = goals;
  }
}
