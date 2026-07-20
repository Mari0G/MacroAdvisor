import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/meals/application/meal_detail_controller.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test(
    'saved-meal edits keep provider data local and mark the entry edited',
    () {
      final original = _entry();
      final draft = MealEditDraftController(original);

      draft.updateOccurrence(DateTime(2026, 3, 29, 3, 30));
      draft.replaceItem(
        MealItem(
          id: 'item-1',
          name: 'Updated beans',
          nutrition: original.items.single.nutrition,
          confidence: MealConfidence.high,
        ),
      );

      expect(draft.entry.userEdited, isTrue);
      expect(draft.entry.occurredAtUtc, DateTime.utc(2026, 3, 29, 1, 30));
      expect(draft.entry.items.single.name, 'Updated beans');
      expect(draft.entry.provenance, same(original.provenance));
    },
  );

  test('saved-meal editor cannot remove its final item', () {
    final draft = MealEditDraftController(_entry());

    draft.removeItem('item-1');

    expect(draft.entry.items, hasLength(1));
  });
}

MealEntry _entry() => MealEntry(
  id: 'meal-1',
  createdAtUtc: DateTime.utc(2026, 3, 29),
  updatedAtUtc: DateTime.utc(2026, 3, 29),
  revision: 2,
  occurredAtUtc: DateTime.utc(2026, 3, 29, 10),
  occurredOffsetMinutes: 120,
  description: 'Beans',
  items: [
    MealItem(
      id: 'item-1',
      name: 'Beans',
      nutrition: NutritionFacts({
        NutrientId.energy: const KnownNutritionValue(
          milliUnits: 250000,
          unit: NutritionUnit.kilocalories,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
      confidence: MealConfidence.medium,
    ),
  ],
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'test-model',
    analyzedAtUtc: DateTime.utc(2026, 3, 29),
    detectedLocale: 'en',
  ),
);
