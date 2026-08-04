import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

enum HistoryPeriodKind { rollingWeek, calendarMonth, customRange }

class HistorySelection {
  const HistorySelection({
    required this.nutrient,
    required this.period,
    required this.anchorDay,
    this.customStart,
    this.customEnd,
  });

  factory HistorySelection.initial(LocalDay anchorDay) => HistorySelection(
    nutrient: NutrientId.energy,
    period: HistoryPeriodKind.rollingWeek,
    anchorDay: anchorDay,
  );

  final NutrientId nutrient;
  final HistoryPeriodKind period;
  final LocalDay anchorDay;
  final LocalDay? customStart;
  final LocalDay? customEnd;

  LocalDay get startDay {
    if (period == HistoryPeriodKind.customRange && customStart != null) {
      return customStart!;
    }
    if (period == HistoryPeriodKind.calendarMonth) {
      return LocalDay(anchorDay.year, anchorDay.month, 1);
    }
    return anchorDay.subtract(6);
  }

  LocalDay get endDay {
    if (period == HistoryPeriodKind.customRange && customEnd != null) {
      return customEnd!;
    }
    if (period == HistoryPeriodKind.calendarMonth) {
      final firstOfNext = anchorDay.month == 12
          ? LocalDay(anchorDay.year + 1, 1, 1)
          : LocalDay(anchorDay.year, anchorDay.month + 1, 1);
      return firstOfNext.subtract(1);
    }
    return anchorDay;
  }

  bool get isValid => !endDay.isBefore(startDay);

  HistorySelection copyWith({
    NutrientId? nutrient,
    HistoryPeriodKind? period,
    LocalDay? anchorDay,
    LocalDay? customStart,
    LocalDay? customEnd,
  }) => HistorySelection(
    nutrient: nutrient ?? this.nutrient,
    period: period ?? this.period,
    anchorDay: anchorDay ?? this.anchorDay,
    customStart: customStart ?? this.customStart,
    customEnd: customEnd ?? this.customEnd,
  );

  @override
  bool operator ==(Object other) =>
      other is HistorySelection &&
      other.nutrient == nutrient &&
      other.period == period &&
      other.anchorDay == anchorDay &&
      other.customStart == customStart &&
      other.customEnd == customEnd;

  @override
  int get hashCode =>
      Object.hash(nutrient, period, anchorDay, customStart, customEnd);
}

class HistoryPoint {
  const HistoryPoint({
    required this.day,
    required this.value,
    required this.isIncomplete,
    required this.hasEntries,
    this.progress,
  });

  final LocalDay day;
  final NutritionValue value;
  final bool isIncomplete;
  final bool hasEntries;
  final GoalProgress? progress;

  bool get isKnown => value is KnownNutritionValue;
}

class HistoryDisplayModel {
  HistoryDisplayModel({
    required this.selection,
    required List<HistoryPoint> points,
    required this.target,
  }) : points = List.unmodifiable(points);

  factory HistoryDisplayModel.fromEntries({
    required HistorySelection selection,
    required Iterable<MealEntry> entries,
    required GoalSet goals,
  }) {
    final target = goals[selection.nutrient];
    final points = <HistoryPoint>[];
    for (
      var day = selection.startDay;
      !day.isAfter(selection.endDay);
      day = day.next()
    ) {
      final dayEntries = entries
          .where((entry) => entry.occursOnLocalDay(day.date))
          .toList(growable: false);
      final values = [
        for (final entry in dayEntries)
          for (final item in entry.items) item.nutrition[selection.nutrient],
      ];
      final known = values.whereType<KnownNutritionValue>().toList();
      final incomplete = values.any((value) => value is UnknownNutritionValue);
      final value = values.isEmpty
          ? KnownNutritionValue(
              milliUnits: 0,
              unit: selection.nutrient.canonicalUnit,
              source: NutritionValueSource.calculated,
            )
          : known.isEmpty
          ? UnknownNutritionValue(
              unit: selection.nutrient.canonicalUnit,
              source: NutritionValueSource.calculated,
            )
          : KnownNutritionValue(
              milliUnits: known.fold(
                0,
                (total, current) => total + current.milliUnits,
              ),
              unit: selection.nutrient.canonicalUnit,
              source: NutritionValueSource.calculated,
            );
      final knownValue = value is KnownNutritionValue
          ? value
          : KnownNutritionValue(
              milliUnits: 0,
              unit: selection.nutrient.canonicalUnit,
              source: NutritionValueSource.calculated,
            );
      points.add(
        HistoryPoint(
          day: day,
          value: value,
          isIncomplete: incomplete,
          hasEntries: dayEntries.isNotEmpty,
          progress: target.isActive
              ? GoalProgress.calculate(
                  target: target,
                  value: knownValue,
                  incomplete: incomplete || value is UnknownNutritionValue,
                )
              : null,
        ),
      );
    }
    return HistoryDisplayModel(
      selection: selection,
      points: points,
      target: target.isActive ? target : null,
    );
  }

  final HistorySelection selection;
  final List<HistoryPoint> points;
  final GoalTarget? target;

  Iterable<HistoryPoint> get completePoints =>
      points.where((point) => point.isKnown && !point.isIncomplete);

  HistoryPoint? get highestComplete {
    final values = completePoints.toList();
    if (values.isEmpty) return null;
    values.sort(_compareValuesDescending);
    return values.first;
  }

  HistoryPoint? get lowestComplete {
    final values = completePoints.toList();
    if (values.isEmpty) return null;
    values.sort(_compareValuesAscending);
    return values.first;
  }

  int get incompleteDays => points.where((point) => point.isIncomplete).length;

  bool get hasRecordedMeals => points.any((point) => point.hasEntries);

  static int _compareValuesDescending(HistoryPoint a, HistoryPoint b) =>
      (b.value as KnownNutritionValue).milliUnits.compareTo(
        (a.value as KnownNutritionValue).milliUnits,
      );

  static int _compareValuesAscending(HistoryPoint a, HistoryPoint b) =>
      (a.value as KnownNutritionValue).milliUnits.compareTo(
        (b.value as KnownNutritionValue).milliUnits,
      );
}

extension on LocalDay {
  bool isBefore(LocalDay other) => _compareTo(other) < 0;

  bool isAfter(LocalDay other) => _compareTo(other) > 0;

  LocalDay subtract(int days) {
    final date = DateTime.utc(year, month, day - days);
    return LocalDay.fromDateTime(date);
  }

  int _compareTo(LocalDay other) => DateTime.utc(
    year,
    month,
    day,
  ).compareTo(DateTime.utc(other.year, other.month, other.day));
}
