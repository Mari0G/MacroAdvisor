import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/history/domain/history.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class ObserveHistoryUseCase {
  const ObserveHistoryUseCase(this._mealRepository);

  final MealRepository _mealRepository;

  Stream<HistoryDisplayModel> call(HistorySelection selection, GoalSet goals) {
    if (!selection.isValid) {
      return Stream.value(
        HistoryDisplayModel.fromEntries(
          selection: selection,
          entries: const [],
          goals: goals,
        ),
      );
    }
    return _mealRepository
        .observeRange(selection.startDay.date, selection.endDay.date)
        .map(
          (entries) => HistoryDisplayModel.fromEntries(
            selection: selection,
            entries: entries,
            goals: goals,
          ),
        );
  }
}

class HistoryController extends Notifier<HistorySelection> {
  @override
  HistorySelection build() =>
      HistorySelection.initial(ref.watch(clockProvider).now().localDay);

  void setNutrient(NutrientId nutrient) =>
      state = state.copyWith(nutrient: nutrient);

  void setPeriod(HistoryPeriodKind period) =>
      state = state.copyWith(period: period);

  void setAnchor(LocalDay day) => state = state.copyWith(anchorDay: day);

  void setCustomRange(LocalDay start, LocalDay end) => state = state.copyWith(
    period: HistoryPeriodKind.customRange,
    customStart: start,
    customEnd: end,
  );
}

final historyControllerProvider =
    NotifierProvider<HistoryController, HistorySelection>(
      HistoryController.new,
    );

final historyDisplayProvider = StreamProvider.autoDispose
    .family<HistoryDisplayModel, HistorySelection>((ref, selection) {
      final goalsValue = ref.watch(activeGoalSetProvider);
      final goals = goalsValue is AsyncData<GoalSet>
          ? goalsValue.value
          : GoalSet.empty();
      return ObserveHistoryUseCase(ref.watch(mealRepositoryProvider))(
        selection,
        goals,
      );
    });

extension on DateTime {
  LocalDay get localDay => LocalDay(year, month, day);
}
