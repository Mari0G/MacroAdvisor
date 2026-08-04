import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/history/domain/history.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test('builds one local-day point per day and distinguishes empty zeroes', () {
    final selection = HistorySelection(
      nutrient: NutrientId.energy,
      period: HistoryPeriodKind.customRange,
      anchorDay: LocalDay(2026, 7, 20),
      customStart: LocalDay(2026, 7, 18),
      customEnd: LocalDay(2026, 7, 20),
    );
    final model = HistoryDisplayModel.fromEntries(
      selection: selection,
      entries: [
        _entry(
          id: 'known',
          occurredAtUtc: DateTime.utc(2026, 7, 17, 23),
          offsetMinutes: 120,
          energy: 250000,
        ),
        _entry(
          id: 'unknown',
          occurredAtUtc: DateTime.utc(2026, 7, 19, 9),
          offsetMinutes: 0,
          energy: null,
        ),
      ],
      goals: GoalSet({NutrientId.energy: const MaximumGoalTarget(300000)}),
    );

    expect(model.points, hasLength(3));
    expect(model.points[0].day, LocalDay(2026, 7, 18));
    expect((model.points[0].value as KnownNutritionValue).milliUnits, 250000);
    expect(model.points[0].hasEntries, isTrue);
    expect(model.points[1].isIncomplete, isTrue);
    expect(model.points[2].hasEntries, isFalse);
    expect((model.points[2].value as KnownNutritionValue).milliUnits, 0);
    expect(model.incompleteDays, 1);
    expect(model.highestComplete!.day, LocalDay(2026, 7, 18));
    expect(model.hasRecordedMeals, isTrue);
  });

  test('uses the recorded offset at daylight-saving boundaries', () {
    final day = LocalDay(2026, 3, 29);
    final selection = HistorySelection(
      nutrient: NutrientId.energy,
      period: HistoryPeriodKind.customRange,
      anchorDay: day,
      customStart: day,
      customEnd: day,
    );
    final model = HistoryDisplayModel.fromEntries(
      selection: selection,
      entries: [
        _entry(
          id: 'dst',
          occurredAtUtc: DateTime.utc(2026, 3, 28, 22, 30),
          offsetMinutes: 120,
          energy: 100000,
        ),
      ],
      goals: GoalSet.empty(),
    );

    expect(model.points.single.hasEntries, isTrue);
  });

  test('rejects an inclusive custom range whose end precedes its start', () {
    final selection = HistorySelection(
      nutrient: NutrientId.energy,
      period: HistoryPeriodKind.customRange,
      anchorDay: LocalDay(2026, 7, 20),
      customStart: LocalDay(2026, 7, 20),
      customEnd: LocalDay(2026, 7, 19),
    );

    expect(selection.isValid, isFalse);
    expect(selection.startDay, LocalDay(2026, 7, 20));
    expect(selection.endDay, LocalDay(2026, 7, 19));
  });
}

MealEntry _entry({
  required String id,
  required DateTime occurredAtUtc,
  required int offsetMinutes,
  required int? energy,
}) => MealEntry(
  id: id,
  createdAtUtc: DateTime.utc(2026, 7, 1),
  updatedAtUtc: DateTime.utc(2026, 7, 1),
  revision: 0,
  occurredAtUtc: occurredAtUtc,
  occurredOffsetMinutes: offsetMinutes,
  items: [
    MealItem(
      id: '$id-item',
      name: id,
      nutrition: NutritionFacts({
        NutrientId.energy: energy == null
            ? const UnknownNutritionValue(
                unit: NutritionUnit.kilocalories,
                source: NutritionValueSource.providerEstimate,
              )
            : KnownNutritionValue(
                milliUnits: energy,
                unit: NutritionUnit.kilocalories,
                source: NutritionValueSource.providerEstimate,
              ),
      }),
      confidence: MealConfidence.medium,
    ),
  ],
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'test',
    analyzedAtUtc: DateTime.utc(2026, 7, 1),
    detectedLocale: 'en',
  ),
);
