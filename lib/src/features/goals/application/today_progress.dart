import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/dashboard/application/dashboard_controller.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class TodayNutrientProgress {
  const TodayNutrientProgress({
    required this.nutrient,
    required this.total,
    required this.target,
    required this.progress,
  });

  final NutrientId nutrient;
  final DashboardNutrientTotal total;
  final GoalTarget target;
  final GoalProgress progress;
}

class TodayProgressModel {
  TodayProgressModel({
    required this.goals,
    required List<TodayNutrientProgress> nutrients,
  }) : nutrients = List.unmodifiable(nutrients);

  factory TodayProgressModel.fromDashboard(
    DashboardDisplayModel dashboard,
    GoalSet goals,
  ) {
    return TodayProgressModel(
      goals: goals,
      nutrients: [
        for (final entry in goals.active)
          _fromTotal(entry.key, entry.value, dashboard[entry.key]),
      ],
    );
  }

  final GoalSet goals;
  final List<TodayNutrientProgress> nutrients;

  bool get hasGoals => goals.hasActiveGoals;

  static TodayNutrientProgress _fromTotal(
    NutrientId nutrient,
    GoalTarget target,
    DashboardNutrientTotal total,
  ) {
    final value = total.value is KnownNutritionValue
        ? total.value as KnownNutritionValue
        : KnownNutritionValue(
            milliUnits: 0,
            unit: nutrient.canonicalUnit,
            source: NutritionValueSource.calculated,
          );
    return TodayNutrientProgress(
      nutrient: nutrient,
      total: total,
      target: target,
      progress: GoalProgress.calculate(
        target: target,
        value: value,
        incomplete: total.isIncomplete || total.value is UnknownNutritionValue,
      ),
    );
  }
}

final todayProgressProvider = Provider.autoDispose
    .family<TodayProgressModel?, LocalDay>((ref, day) {
      final dashboardValue = ref.watch(dashboardDisplayProvider(day));
      final goalsValue = ref.watch(activeGoalSetProvider);
      final dashboard = dashboardValue is AsyncData<DashboardDisplayModel>
          ? dashboardValue.value
          : null;
      final goals = goalsValue is AsyncData<GoalSet> ? goalsValue.value : null;
      if (dashboard == null || goals == null) return null;
      return TodayProgressModel.fromDashboard(dashboard, goals);
    });
