import 'package:flutter/material.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

String goalTargetText(
  BuildContext context,
  NutrientId nutrient,
  GoalTarget target,
) {
  final l10n = AppLocalizations.of(context);
  String formatted(int milliUnits) => nutritionValueText(
    context,
    KnownNutritionValue(
      milliUnits: milliUnits,
      unit: nutrient.canonicalUnit,
      source: NutritionValueSource.calculated,
    ),
  );
  return switch (target) {
    OffGoalTarget() => l10n.goalTypeOff,
    MinimumGoalTarget(:final value) => l10n.goalMinimumTarget(formatted(value)),
    MaximumGoalTarget(:final value) => l10n.goalMaximumTarget(formatted(value)),
    RangeGoalTarget(:final minimum, :final maximum) => l10n.goalRangeTarget(
      formatted(minimum),
      formatted(maximum),
    ),
  };
}

String goalStatusText(AppLocalizations l10n, GoalProgressStatus status) =>
    switch (status) {
      GoalProgressStatus.belowMinimum => l10n.goalStatusBelowMinimum,
      GoalProgressStatus.withinTarget => l10n.goalStatusWithinTarget,
      GoalProgressStatus.aboveMaximum => l10n.goalStatusAboveMaximum,
      GoalProgressStatus.incomplete => l10n.goalStatusIncomplete,
    };
