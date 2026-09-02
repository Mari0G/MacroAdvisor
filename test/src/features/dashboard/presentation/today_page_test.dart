import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/dashboard/application/dashboard_controller.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/dashboard/presentation/today_page.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  testWidgets('renders empty English dashboard with accessible entry action', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_model(const []), const Locale('en')));

    expect(find.text('No meals or drinks recorded'), findsOneWidget);
    expect(find.text('Record meal'), findsNWidgets(2));
    expect(find.bySemanticsLabel('Selected day'), findsOneWidget);
  });

  testWidgets('renders German populated and incomplete dashboard', (
    tester,
  ) async {
    final entry = _entry(
      id: 'lunch',
      description: 'Mittagessen',
      items: [_item(energyMilli: 500000)],
    );
    await tester.pumpWidget(
      _app(
        DashboardDisplayModel.fromEntries(LocalDay(2026, 7, 20), [entry]),
        const Locale('de'),
      ),
    );

    expect(find.text('Mittagessen'), findsOneWidget);
    expect(find.text('Unvollständige Daten'), findsWidgets);
    expect(find.text('Alle Nährstoffe'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Energie')), findsWidgets);
  });

  testWidgets('opens a saved meal from the dashboard entry list', (
    tester,
  ) async {
    final entry = _entry(
      id: 'meal-1',
      description: 'Lunch',
      items: [_item(energyMilli: 500000)],
    );
    String? openedId;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TodayView(
          day: LocalDay(2026, 7, 20),
          currentDay: LocalDay(2026, 7, 20),
          dashboard: AsyncValue.data(_model([entry])),
          onSelectDay: (_) {},
          onOpenSettings: () {},
          onRecordMeal: () {},
          onOpenMealDetail: (id) => openedId = id,
          onRetry: () {},
        ),
      ),
    );

    await tester.ensureVisible(find.text('Lunch'));
    await tester.tap(find.text('Lunch'));

    expect(openedId, 'meal-1');
  });

  testWidgets(
    'renders localized goal progress with accessible target semantics',
    (tester) async {
      final entry = _entry(
        id: 'meal-1',
        description: 'Lunch',
        items: [_item(energyMilli: 500000)],
      );
      await tester.pumpWidget(
        _app(
          _model([entry]),
          const Locale('en'),
          goals: GoalSet({NutrientId.energy: const MinimumGoalTarget(800000)}),
        ),
      );

      expect(find.text('Progress toward goals'), findsOneWidget);
      expect(find.text('Below minimum'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Energy: current')), findsOneWidget);
    },
  );

  testWidgets(
    'keeps incomplete goal progress cards within a Pixel-width layout',
    (tester) async {
      tester.view.physicalSize = const Size(432, 969);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final entry = _entry(
        id: 'meal-1',
        description: 'Lunch',
        items: [_item(energyMilli: 500000)],
      );
      await tester.pumpWidget(
        _app(
          _model([entry]),
          const Locale('de'),
          goals: GoalSet({
            NutrientId.fibre: const MinimumGoalTarget(25000),
            NutrientId.sugars: const MaximumGoalTarget(30000),
          }),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Ballaststoffe'), findsOneWidget);
      expect(find.text('Zucker'), findsOneWidget);
      expect(find.text('Unvollständige Daten'), findsWidgets);
    },
  );

  testWidgets('preserves compact and expanded layout semantics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(_model(const []), const Locale('en')));
    expect(find.byKey(const Key('today-expanded-layout')), findsOneWidget);
    expect(find.byKey(const Key('today-compact-layout')), findsNothing);
  });
}

Widget _app(DashboardDisplayModel model, Locale locale, {GoalSet? goals}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TodayView(
        day: model.day,
        currentDay: model.day,
        dashboard: AsyncValue.data(model),
        goals: AsyncValue.data(goals ?? GoalSet.empty()),
        onSelectDay: (_) {},
        onOpenSettings: () {},
        onRecordMeal: () {},
        onOpenMealDetail: (_) {},
        onRetry: () {},
      ),
    );

DashboardDisplayModel _model(List<MealEntry> entries) =>
    DashboardDisplayModel.fromEntries(LocalDay(2026, 7, 20), entries);

MealEntry _entry({
  required String id,
  required String description,
  required List<MealItem> items,
}) => MealEntry(
  id: id,
  createdAtUtc: DateTime.utc(2026, 7, 20),
  updatedAtUtc: DateTime.utc(2026, 7, 20),
  revision: 0,
  occurredAtUtc: DateTime.utc(2026, 7, 20, 12),
  occurredOffsetMinutes: 120,
  description: description,
  items: items,
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'test',
    analyzedAtUtc: DateTime.utc(2026, 7, 20),
    detectedLocale: 'de',
  ),
);

MealItem _item({required int energyMilli}) => MealItem(
  id: 'item',
  name: 'Item',
  nutrition: NutritionFacts({
    NutrientId.energy: KnownNutritionValue(
      milliUnits: energyMilli,
      unit: NutritionUnit.kilocalories,
      source: NutritionValueSource.providerEstimate,
    ),
  }),
  confidence: MealConfidence.medium,
);
