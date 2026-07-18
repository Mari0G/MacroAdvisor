import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test('sums fixed-point values without rounding drift', () {
    final total = NutritionFacts.sum([
      NutritionFacts({
        NutrientId.protein: const KnownNutritionValue(
          milliUnits: 100,
          unit: NutritionUnit.grams,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
      NutritionFacts({
        NutrientId.protein: const KnownNutritionValue(
          milliUnits: 200,
          unit: NutritionUnit.grams,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
    ]);

    expect((total[NutrientId.protein] as KnownNutritionValue).milliUnits, 300);
  });

  test('keeps an aggregate unknown when any contributing item is unknown', () {
    final total = NutritionFacts.sum([
      NutritionFacts({
        NutrientId.fibre: const KnownNutritionValue(
          milliUnits: 1200,
          unit: NutritionUnit.grams,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
      NutritionFacts({
        NutrientId.fibre: const UnknownNutritionValue(
          unit: NutritionUnit.grams,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
    ]);

    expect(total[NutrientId.fibre], isA<UnknownNutritionValue>());
  });

  test('rejects a value with a non-canonical unit', () {
    expect(
      () => NutritionFacts({
        NutrientId.energy: const KnownNutritionValue(
          milliUnits: 1,
          unit: NutritionUnit.grams,
          source: NutritionValueSource.userEdited,
        ),
      }),
      throwsArgumentError,
    );
  });
}
