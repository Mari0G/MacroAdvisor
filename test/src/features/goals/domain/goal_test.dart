import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test('supports off, minimum, maximum, and inclusive range targets', () {
    expect(GoalTarget.fromValues(GoalTargetKind.off), const OffGoalTarget());
    expect(
      GoalTarget.fromValues(GoalTargetKind.minimum, minimumMilliUnits: 25000),
      const MinimumGoalTarget(25000),
    );
    expect(
      GoalTarget.fromValues(GoalTargetKind.maximum, maximumMilliUnits: 80000),
      const MaximumGoalTarget(80000),
    );
    expect(
      GoalTarget.fromValues(
        GoalTargetKind.range,
        minimumMilliUnits: 25000,
        maximumMilliUnits: 80000,
      ),
      const RangeGoalTarget(25000, 80000),
    );
  });

  test('rejects negative and reversed target values', () {
    expect(
      () =>
          GoalTarget.fromValues(GoalTargetKind.minimum, minimumMilliUnits: -1),
      throwsArgumentError,
    );
    expect(
      () => GoalTarget.fromValues(
        GoalTargetKind.range,
        minimumMilliUnits: 90000,
        maximumMilliUnits: 80000,
      ),
      throwsArgumentError,
    );
  });

  test('calculates target status without relying on color', () {
    const value = KnownNutritionValue(
      milliUnits: 50000,
      unit: NutritionUnit.grams,
      source: NutritionValueSource.calculated,
    );

    expect(
      GoalProgress.calculate(
        target: const MinimumGoalTarget(60000),
        value: value,
        incomplete: false,
      ).status,
      GoalProgressStatus.belowMinimum,
    );
    expect(
      GoalProgress.calculate(
        target: const RangeGoalTarget(50000, 70000),
        value: value,
        incomplete: false,
      ).status,
      GoalProgressStatus.withinTarget,
    );
    expect(
      GoalProgress.calculate(
        target: const MaximumGoalTarget(40000),
        value: value,
        incomplete: false,
      ).status,
      GoalProgressStatus.aboveMaximum,
    );
    expect(
      GoalProgress.calculate(
        target: const MinimumGoalTarget(60000),
        value: value,
        incomplete: true,
      ).ratio,
      isNull,
    );
  });

  test('goal set defaults every core nutrient to off', () {
    final goals = GoalSet({NutrientId.protein: const MinimumGoalTarget(50000)});

    expect(goals[NutrientId.protein], const MinimumGoalTarget(50000));
    expect(goals[NutrientId.energy], const OffGoalTarget());
    expect(goals.active, hasLength(1));
  });
}
