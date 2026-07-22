import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class DashboardNutrientTotal {
  const DashboardNutrientTotal({
    required this.nutrient,
    required this.value,
    required this.isIncomplete,
  });

  final NutrientId nutrient;
  final NutritionValue value;
  final bool isIncomplete;

  bool get isKnown => value is KnownNutritionValue;
}

class DashboardDisplayModel {
  DashboardDisplayModel({
    required this.day,
    required List<MealEntry> entries,
    required Map<NutrientId, DashboardNutrientTotal> nutrients,
  }) : entries = List.unmodifiable(entries),
       nutrients = Map.unmodifiable(nutrients);

  factory DashboardDisplayModel.fromEntries(
    LocalDay day,
    Iterable<MealEntry> sourceEntries,
  ) {
    final entries = sourceEntries.toList()
      ..sort((a, b) => _localOccurrence(b).compareTo(_localOccurrence(a)));
    final nutrients = <NutrientId, DashboardNutrientTotal>{};
    for (final nutrient in NutrientId.core) {
      final values = [
        for (final entry in entries)
          for (final item in entry.items) item.nutrition[nutrient],
      ];
      final known = values.whereType<KnownNutritionValue>().toList();
      final incomplete = values.any((value) => value is UnknownNutritionValue);
      final value = known.isEmpty
          ? UnknownNutritionValue(
              unit: nutrient.canonicalUnit,
              source: NutritionValueSource.calculated,
            )
          : KnownNutritionValue(
              milliUnits: known.fold(
                0,
                (total, current) => total + current.milliUnits,
              ),
              unit: nutrient.canonicalUnit,
              source: NutritionValueSource.calculated,
            );
      nutrients[nutrient] = DashboardNutrientTotal(
        nutrient: nutrient,
        value: entries.isEmpty
            ? KnownNutritionValue(
                milliUnits: 0,
                unit: nutrient.canonicalUnit,
                source: NutritionValueSource.calculated,
              )
            : value,
        isIncomplete: incomplete,
      );
    }
    return DashboardDisplayModel(
      day: day,
      entries: entries,
      nutrients: nutrients,
    );
  }

  final LocalDay day;
  final List<MealEntry> entries;
  final Map<NutrientId, DashboardNutrientTotal> nutrients;

  bool get isEmpty => entries.isEmpty;
  bool get hasIncompleteData =>
      nutrients.values.any((total) => total.isIncomplete);

  DashboardNutrientTotal operator [](NutrientId nutrient) =>
      nutrients[nutrient]!;

  static DateTime _localOccurrence(MealEntry entry) =>
      entry.occurredAtUtc.add(Duration(minutes: entry.occurredOffsetMinutes));
}

class ObserveDayUseCase {
  const ObserveDayUseCase(this._repository);

  final MealRepository _repository;

  Stream<DashboardDisplayModel> call(LocalDay day) => _repository
      .observeDay(day.date)
      .map((entries) => DashboardDisplayModel.fromEntries(day, entries));
}

class DashboardController extends Notifier<LocalDay> {
  @override
  LocalDay build() => LocalDay.fromDateTime(ref.watch(clockProvider).now());

  void selectDay(LocalDay day) => state = day;

  void selectPreviousDay() => state = state.previous();

  void selectNextDay() => state = state.next();
}

final dashboardControllerProvider =
    NotifierProvider<DashboardController, LocalDay>(DashboardController.new);

final dashboardDisplayProvider = StreamProvider.autoDispose
    .family<DashboardDisplayModel, LocalDay>((ref, day) {
      return ObserveDayUseCase(ref.watch(mealRepositoryProvider))(day);
    });
