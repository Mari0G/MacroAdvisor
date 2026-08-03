import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

enum GoalTargetKind { off, minimum, maximum, range }

sealed class GoalTarget {
  const GoalTarget._(this.kind);

  final GoalTargetKind kind;

  int? get minimumMilliUnits;
  int? get maximumMilliUnits;

  bool get isActive => kind != GoalTargetKind.off;

  static GoalTarget fromValues(
    GoalTargetKind kind, {
    int? minimumMilliUnits,
    int? maximumMilliUnits,
  }) {
    final error = validate(
      kind,
      minimumMilliUnits: minimumMilliUnits,
      maximumMilliUnits: maximumMilliUnits,
    );
    if (error != null) throw ArgumentError(error);
    return switch (kind) {
      GoalTargetKind.off => const OffGoalTarget(),
      GoalTargetKind.minimum => MinimumGoalTarget(minimumMilliUnits!),
      GoalTargetKind.maximum => MaximumGoalTarget(maximumMilliUnits!),
      GoalTargetKind.range => RangeGoalTarget(
        minimumMilliUnits!,
        maximumMilliUnits!,
      ),
    };
  }

  static String? validate(
    GoalTargetKind kind, {
    int? minimumMilliUnits,
    int? maximumMilliUnits,
  }) {
    if (kind == GoalTargetKind.off) return null;
    if (kind == GoalTargetKind.minimum &&
        (minimumMilliUnits == null || minimumMilliUnits < 0)) {
      return 'Minimum target must be finite and non-negative.';
    }
    if (kind == GoalTargetKind.maximum &&
        (maximumMilliUnits == null || maximumMilliUnits < 0)) {
      return 'Maximum target must be finite and non-negative.';
    }
    if (kind == GoalTargetKind.range &&
        (minimumMilliUnits == null ||
            maximumMilliUnits == null ||
            minimumMilliUnits < 0 ||
            maximumMilliUnits < 0)) {
      return 'Range targets must be finite and non-negative.';
    }
    if (kind == GoalTargetKind.range &&
        minimumMilliUnits! > maximumMilliUnits!) {
      return 'Range minimum must not exceed maximum.';
    }
    return null;
  }
}

final class OffGoalTarget extends GoalTarget {
  const OffGoalTarget() : super._(GoalTargetKind.off);

  @override
  int? get minimumMilliUnits => null;

  @override
  int? get maximumMilliUnits => null;

  @override
  bool operator ==(Object other) => other is OffGoalTarget;

  @override
  int get hashCode => kind.hashCode;
}

final class MinimumGoalTarget extends GoalTarget {
  const MinimumGoalTarget(this.value) : super._(GoalTargetKind.minimum);

  final int value;

  @override
  int get minimumMilliUnits => value;

  @override
  int? get maximumMilliUnits => null;

  @override
  bool operator ==(Object other) =>
      other is MinimumGoalTarget && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);
}

final class MaximumGoalTarget extends GoalTarget {
  const MaximumGoalTarget(this.value) : super._(GoalTargetKind.maximum);

  final int value;

  @override
  int? get minimumMilliUnits => null;

  @override
  int get maximumMilliUnits => value;

  @override
  bool operator ==(Object other) =>
      other is MaximumGoalTarget && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);
}

final class RangeGoalTarget extends GoalTarget {
  const RangeGoalTarget(this.minimum, this.maximum)
    : assert(minimum >= 0),
      assert(maximum >= minimum),
      super._(GoalTargetKind.range);

  final int minimum;
  final int maximum;

  @override
  int get minimumMilliUnits => minimum;

  @override
  int get maximumMilliUnits => maximum;

  @override
  bool operator ==(Object other) =>
      other is RangeGoalTarget &&
      other.minimum == minimum &&
      other.maximum == maximum;

  @override
  int get hashCode => Object.hash(kind, minimum, maximum);
}

class GoalSet {
  GoalSet(Map<NutrientId, GoalTarget> values)
    : _values = Map.unmodifiable({
        for (final nutrient in NutrientId.core)
          nutrient: values[nutrient] ?? const OffGoalTarget(),
        ...values,
      });

  factory GoalSet.empty() => GoalSet({});

  final Map<NutrientId, GoalTarget> _values;

  Map<NutrientId, GoalTarget> get values => _values;

  GoalTarget operator [](NutrientId nutrient) =>
      _values[nutrient] ?? const OffGoalTarget();

  Iterable<MapEntry<NutrientId, GoalTarget>> get active =>
      _values.entries.where((entry) => entry.value.isActive);

  bool get hasActiveGoals => active.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is GoalSet &&
      _values.length == other._values.length &&
      _values.entries.every((entry) => other[entry.key] == entry.value);

  @override
  int get hashCode => Object.hashAll(
    _values.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}

enum GoalProgressStatus { belowMinimum, withinTarget, aboveMaximum, incomplete }

class GoalProgress {
  const GoalProgress({
    required this.target,
    required this.value,
    required this.status,
    required this.ratio,
  });

  final GoalTarget target;
  final KnownNutritionValue value;
  final GoalProgressStatus status;
  final double? ratio;

  bool get isIncomplete => status == GoalProgressStatus.incomplete;

  static GoalProgress calculate({
    required GoalTarget target,
    required KnownNutritionValue value,
    required bool incomplete,
  }) {
    if (incomplete) {
      return GoalProgress(
        target: target,
        value: value,
        status: GoalProgressStatus.incomplete,
        ratio: null,
      );
    }
    final current = value.milliUnits;
    final status = switch (target) {
      OffGoalTarget() => GoalProgressStatus.withinTarget,
      MinimumGoalTarget(:final value) =>
        current < value
            ? GoalProgressStatus.belowMinimum
            : GoalProgressStatus.withinTarget,
      MaximumGoalTarget(:final value) =>
        current > value
            ? GoalProgressStatus.aboveMaximum
            : GoalProgressStatus.withinTarget,
      RangeGoalTarget(:final minimum, :final maximum) =>
        current < minimum
            ? GoalProgressStatus.belowMinimum
            : current > maximum
            ? GoalProgressStatus.aboveMaximum
            : GoalProgressStatus.withinTarget,
    };
    final ratio = switch (target) {
      OffGoalTarget() => null,
      MinimumGoalTarget(:final value) =>
        value == 0 ? 1.0 : (current / value).clamp(0, 1).toDouble(),
      MaximumGoalTarget(:final value) =>
        value == 0
            ? (current == 0 ? 1.0 : 0.0)
            : (current / value).clamp(0, 1).toDouble(),
      RangeGoalTarget(:final maximum) =>
        maximum == 0
            ? (current == 0 ? 1.0 : 0.0)
            : (current / maximum).clamp(0, 1).toDouble(),
    };
    return GoalProgress(
      target: target,
      value: value,
      status: status,
      ratio: ratio,
    );
  }
}
