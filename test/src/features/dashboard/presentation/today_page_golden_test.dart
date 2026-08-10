import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_theme.dart';
import 'package:macro_advisor/src/features/dashboard/application/dashboard_controller.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/dashboard/presentation/today_page.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  setUp(() {
    final previousComparator = goldenFileComparator;
    if (previousComparator is LocalFileComparator) {
      goldenFileComparator = _TolerantGoldenFileComparator(
        previousComparator,
        precisionTolerance: .04,
      );
      addTearDown(() => goldenFileComparator = previousComparator);
    }
  });

  testWidgets('renders the English populated Today baseline', (tester) async {
    _configureCompactView(tester);

    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TodayView),
      matchesGoldenFile('goldens/today_dashboard_en.png'),
    );
  });

  testWidgets('renders the German populated Today baseline', (tester) async {
    _configureCompactView(tester);

    await tester.pumpWidget(_app(const Locale('de')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TodayView),
      matchesGoldenFile('goldens/today_dashboard_de.png'),
    );
  });
}

/// Allows small font-rasterization differences between local Windows runs and
/// the Linux CI renderer while still failing on meaningful layout changes.
class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(
    LocalFileComparator original, {
    required double precisionTolerance,
  }) : assert(
         precisionTolerance >= 0 && precisionTolerance <= 1,
         'precisionTolerance must be between 0 and 1',
       ),
       _precisionTolerance = precisionTolerance,
       super(original.basedir.resolve('today_page_golden_test.dart'));

  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final passed = result.passed || result.diffPercent <= _precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

void _configureCompactView(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Locale locale) {
  final theme = AppTheme.light();
  return MaterialApp(
    locale: locale,
    // Pin the test font so the checked-in pixels match Linux CI and local runs.
    theme: theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamily: 'Ahem'),
      primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Ahem'),
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: TodayView(
      day: LocalDay(2026, 7, 20),
      currentDay: LocalDay(2026, 7, 20),
      dashboard: AsyncValue.data(
        DashboardDisplayModel.fromEntries(LocalDay(2026, 7, 20), [_entry()]),
      ),
      onSelectDay: (_) {},
      onOpenSettings: () {},
      onRecordMeal: () {},
      onOpenMealDetail: (_) {},
      onRetry: () {},
    ),
  );
}

MealEntry _entry() => MealEntry(
  id: 'golden-meal',
  createdAtUtc: DateTime.utc(2026, 7, 20, 10),
  updatedAtUtc: DateTime.utc(2026, 7, 20, 10),
  revision: 0,
  occurredAtUtc: DateTime.utc(2026, 7, 20, 10),
  occurredOffsetMinutes: 120,
  description: 'Greek yogurt with banana and almonds',
  items: [
    MealItem(
      id: 'golden-item',
      name: 'Greek yogurt with banana and almonds',
      amountDescription: '1 serving',
      nutrition: NutritionFacts({
        NutrientId.energy: const KnownNutritionValue(
          milliUnits: 450000,
          unit: NutritionUnit.kilocalories,
          source: NutritionValueSource.providerEstimate,
        ),
        NutrientId.protein: const KnownNutritionValue(
          milliUnits: 20000,
          unit: NutritionUnit.grams,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
      confidence: MealConfidence.medium,
    ),
  ],
  provenance: MealProvenance(
    providerId: 'deterministic-fake',
    modelId: 'local-fixture-v1',
    analyzedAtUtc: DateTime.utc(2026, 7, 20, 10),
    detectedLocale: 'en',
  ),
  confidence: MealConfidence.medium,
  assumptions: const [
    MealAssumption(
      code: 'portion-default',
      description: 'A standard serving size was assumed.',
    ),
  ],
);
