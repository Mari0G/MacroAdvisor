import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/history/domain/history.dart';
import 'package:macro_advisor/src/features/history/presentation/history_page.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  testWidgets('renders empty history with textual chart alternative', (
    tester,
  ) async {
    final selection = HistorySelection.initial(LocalDay(2026, 7, 20));
    final model = HistoryDisplayModel.fromEntries(
      selection: selection,
      entries: const [],
      goals: GoalSet.empty(),
    );
    await tester.pumpWidget(
      _app(
        HistoryView(
          selection: selection,
          history: AsyncValue.data(model),
          onNutrientChanged: (_) {},
          onPeriodChanged: (_) {},
          onAnchorChanged: (_) {},
          onCustomRangeChanged: (_, _) {},
          onRetry: () {},
        ),
      ),
    );

    expect(
      find.text('No meals were recorded for this period.'),
      findsOneWidget,
    );
    expect(find.text('Daily values'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Daily nutrition chart; values are also listed below.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('history-nutrient-selector')), findsOneWidget);
  });

  testWidgets('shows German period controls and incomplete daily state', (
    tester,
  ) async {
    final selection = HistorySelection(
      nutrient: NutrientId.energy,
      period: HistoryPeriodKind.customRange,
      anchorDay: LocalDay(2026, 7, 20),
      customStart: LocalDay(2026, 7, 20),
      customEnd: LocalDay(2026, 7, 20),
    );
    final model = HistoryDisplayModel.fromEntries(
      selection: selection,
      entries: [_entry()],
      goals: GoalSet.empty(),
    );
    await tester.pumpWidget(
      _app(
        HistoryView(
          selection: selection,
          history: AsyncValue.data(model),
          onNutrientChanged: (_) {},
          onPeriodChanged: (_) {},
          onAnchorChanged: (_) {},
          onCustomRangeChanged: (_, _) {},
          onRetry: () {},
        ),
        locale: const Locale('de'),
      ),
    );

    expect(find.text('Unvollständig'), findsOneWidget);
    expect(find.text('Benutzerdefinierter Zeitraum'), findsOneWidget);
    expect(find.text('Tageswerte'), findsOneWidget);
  });
}

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

MealEntry _entry() => MealEntry(
  id: 'unknown',
  createdAtUtc: DateTime.utc(2026, 7, 20),
  updatedAtUtc: DateTime.utc(2026, 7, 20),
  revision: 0,
  occurredAtUtc: DateTime.utc(2026, 7, 20, 12),
  occurredOffsetMinutes: 0,
  items: [
    MealItem(
      id: 'item',
      name: 'Unknown',
      nutrition: NutritionFacts({
        NutrientId.energy: const UnknownNutritionValue(
          unit: NutritionUnit.kilocalories,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
      confidence: MealConfidence.low,
    ),
  ],
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'test',
    analyzedAtUtc: DateTime.utc(2026, 7, 20),
    detectedLocale: 'de',
  ),
);
