import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/dashboard/application/dashboard_controller.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test('LocalDay advances across daylight-saving calendar boundaries', () {
    final day = LocalDay(2026, 3, 29);

    expect(day.previous(), LocalDay(2026, 3, 28));
    expect(day.next(), LocalDay(2026, 3, 30));
    expect(day.contains(DateTime(2026, 3, 29, 23, 59)), isTrue);
    expect(day.contains(DateTime(2026, 3, 30)), isFalse);
  });

  test('aggregates known nutrients and preserves incomplete totals', () {
    final model = DashboardDisplayModel.fromEntries(LocalDay(2026, 7, 20), [
      _entry(
        description: 'Dinner',
        occurredAtUtc: DateTime.utc(2026, 7, 20, 17),
        items: [_item(name: 'Beans', energyMilli: 450000, proteinMilli: 25000)],
      ),
      _entry(
        description: 'Snack',
        occurredAtUtc: DateTime.utc(2026, 7, 20, 19),
        items: [_item(name: 'Fruit', energyMilli: 100000)],
      ),
    ]);

    expect(model.entries.map((entry) => entry.description), [
      'Snack',
      'Dinner',
    ]);
    expect(
      (model[NutrientId.energy].value as KnownNutritionValue).milliUnits,
      550000,
    );
    expect(model[NutrientId.protein].isIncomplete, isTrue);
    expect(model.hasIncompleteData, isTrue);
  });

  test('observe-day use case forwards repository updates', () async {
    final controller = StreamController<List<MealEntry>>();
    final repository = _StreamingRepository(controller.stream);
    final stream = ObserveDayUseCase(repository)(LocalDay(2026, 7, 20));
    final expectation = expectLater(
      stream.map((model) => model.entries.length),
      emitsInOrder([0, 1]),
    );

    controller.add(const []);
    controller.add([
      _entry(
        description: 'Lunch',
        occurredAtUtc: DateTime.utc(2026, 7, 20, 12),
        items: [_item(name: 'Lunch', energyMilli: 300000)],
      ),
    ]);
    await expectation;
    await controller.close();
  });
}

class _StreamingRepository implements MealRepository {
  _StreamingRepository(this._stream);

  final Stream<List<MealEntry>> _stream;

  @override
  Stream<List<MealEntry>> observeDay(DateTime localDay) => _stream;

  @override
  Future<MealEntry> create(MealEntryDraft draft) => throw UnimplementedError();

  @override
  Future<MealEntry?> findById(String id, {bool includeDeleted = false}) =>
      throw UnimplementedError();

  @override
  Future<MealEntry> update(MealEntry entry) => throw UnimplementedError();

  @override
  Future<MealEntry> softDelete({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();

  @override
  Future<MealEntry> restore({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();
}

MealEntry _entry({
  required String description,
  required DateTime occurredAtUtc,
  required List<MealItem> items,
  int occurredOffsetMinutes = 0,
}) => MealEntry(
  id: description,
  createdAtUtc: DateTime.utc(2026, 7, 20),
  updatedAtUtc: DateTime.utc(2026, 7, 20),
  revision: 0,
  occurredAtUtc: occurredAtUtc,
  occurredOffsetMinutes: occurredOffsetMinutes,
  description: description,
  items: items,
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'test',
    analyzedAtUtc: DateTime.utc(2026, 7, 20),
    detectedLocale: 'en',
  ),
);

MealItem _item({
  required String name,
  required int energyMilli,
  int? proteinMilli,
}) => MealItem(
  id: name,
  name: name,
  nutrition: NutritionFacts({
    NutrientId.energy: KnownNutritionValue(
      milliUnits: energyMilli,
      unit: NutritionUnit.kilocalories,
      source: NutritionValueSource.providerEstimate,
    ),
    if (proteinMilli != null)
      NutrientId.protein: KnownNutritionValue(
        milliUnits: proteinMilli,
        unit: NutritionUnit.grams,
        source: NutritionValueSource.providerEstimate,
      ),
  }),
  confidence: MealConfidence.medium,
);
