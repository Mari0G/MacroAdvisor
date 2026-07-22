import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

sealed class GoalTarget {
  const GoalTarget();

  int? get minimumMilliUnits;
  int? get maximumMilliUnits;
}

class MinimumGoalTarget extends GoalTarget {
  const MinimumGoalTarget(this.minimumMilliUnits)
    : assert(minimumMilliUnits >= 0);

  @override
  final int minimumMilliUnits;

  @override
  int? get maximumMilliUnits => null;
}

class MaximumGoalTarget extends GoalTarget {
  const MaximumGoalTarget(this.maximumMilliUnits)
    : assert(maximumMilliUnits >= 0);

  @override
  int? get minimumMilliUnits => null;

  @override
  final int maximumMilliUnits;
}

class RangeGoalTarget extends GoalTarget {
  const RangeGoalTarget(this.minimumMilliUnits, this.maximumMilliUnits)
    : assert(minimumMilliUnits >= 0),
      assert(maximumMilliUnits >= minimumMilliUnits);

  @override
  final int minimumMilliUnits;

  @override
  final int maximumMilliUnits;
}

/// The configured daily targets. A missing map value means that nutrient is off.
class GoalSet {
  GoalSet(Map<NutrientId, GoalTarget> targets)
    : targets = Map.unmodifiable(targets) {
    for (final target in this.targets.values) {
      final minimum = target.minimumMilliUnits;
      final maximum = target.maximumMilliUnits;
      if ((minimum != null && minimum < 0) ||
          (maximum != null && maximum < 0) ||
          (minimum != null && maximum != null && minimum > maximum)) {
        throw ArgumentError.value(target, 'targets', 'Invalid goal target.');
      }
    }
  }

  GoalSet.empty() : this(const {});

  final Map<NutrientId, GoalTarget> targets;

  GoalTarget? operator [](NutrientId nutrient) => targets[nutrient];
}

enum GoalProgressStatus {
  noGoal,
  unknown,
  belowTarget,
  withinTarget,
  aboveTarget,
}

class GoalProgress {
  const GoalProgress({
    required this.nutrient,
    required this.value,
    required this.target,
    required this.status,
  });

  factory GoalProgress.calculate({
    required NutrientId nutrient,
    required NutritionValue value,
    required GoalTarget? target,
  }) {
    if (target == null) {
      return GoalProgress(
        nutrient: nutrient,
        value: value,
        target: null,
        status: GoalProgressStatus.noGoal,
      );
    }
    if (value is! KnownNutritionValue) {
      return GoalProgress(
        nutrient: nutrient,
        value: value,
        target: target,
        status: GoalProgressStatus.unknown,
      );
    }
    final current = value.milliUnits;
    final minimum = target.minimumMilliUnits;
    final maximum = target.maximumMilliUnits;
    final status = minimum != null && current < minimum
        ? GoalProgressStatus.belowTarget
        : maximum != null && current > maximum
        ? GoalProgressStatus.aboveTarget
        : GoalProgressStatus.withinTarget;
    return GoalProgress(
      nutrient: nutrient,
      value: value,
      target: target,
      status: status,
    );
  }

  final NutrientId nutrient;
  final NutritionValue value;
  final GoalTarget? target;
  final GoalProgressStatus status;
}
