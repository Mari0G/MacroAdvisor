import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test('rejects invalid target ranges', () {
    expect(
      () => GoalSet({NutrientId.protein: RangeGoalTarget(20000, 10000)}),
      throwsA(isA<AssertionError>()),
    );
  });

  test('calculates minimum, maximum, range, and unknown progress', () {
    final value = const KnownNutritionValue(
      milliUnits: 25000,
      unit: NutritionUnit.grams,
      source: NutritionValueSource.calculated,
    );
    expect(
      GoalProgress.calculate(
        nutrient: NutrientId.protein,
        value: value,
        target: const MinimumGoalTarget(30000),
      ).status,
      GoalProgressStatus.belowTarget,
    );
    expect(
      GoalProgress.calculate(
        nutrient: NutrientId.protein,
        value: value,
        target: const MaximumGoalTarget(20000),
      ).status,
      GoalProgressStatus.aboveTarget,
    );
    expect(
      GoalProgress.calculate(
        nutrient: NutrientId.protein,
        value: value,
        target: const RangeGoalTarget(20000, 30000),
      ).status,
      GoalProgressStatus.withinTarget,
    );
    expect(
      GoalProgress.calculate(
        nutrient: NutrientId.protein,
        value: const UnknownNutritionValue(
          unit: NutritionUnit.grams,
          source: NutritionValueSource.calculated,
        ),
        target: const MinimumGoalTarget(30000),
      ).status,
      GoalProgressStatus.unknown,
    );
  });
}
