/// Nutrition primitives deliberately use integer thousandths of canonical units.
///
/// This keeps calculations deterministic and avoids persisting floating-point
/// values. Formatting and locale-specific decimal input belong at the UI edge.
enum NutritionUnit { kilocalories, grams }

class NutrientId {
  const NutrientId(this.value, this.canonicalUnit);

  final String value;
  final NutritionUnit canonicalUnit;

  static const energy = NutrientId('energy', NutritionUnit.kilocalories);
  static const protein = NutrientId('protein', NutritionUnit.grams);
  static const carbohydrates = NutrientId('carbohydrates', NutritionUnit.grams);
  static const fat = NutrientId('fat', NutritionUnit.grams);
  static const fibre = NutrientId('fibre', NutritionUnit.grams);
  static const sugars = NutrientId('sugars', NutritionUnit.grams);
  static const salt = NutrientId('salt', NutritionUnit.grams);

  static const core = <NutrientId>[
    energy,
    protein,
    carbohydrates,
    fat,
    fibre,
    sugars,
    salt,
  ];

  @override
  bool operator ==(Object other) =>
      other is NutrientId &&
      value == other.value &&
      canonicalUnit == other.canonicalUnit;

  @override
  int get hashCode => Object.hash(value, canonicalUnit);
}

enum NutritionValueSource { providerEstimate, userEdited, calculated }

sealed class NutritionValue {
  const NutritionValue({required this.unit, required this.source});

  final NutritionUnit unit;
  final NutritionValueSource source;

  bool get isKnown => this is KnownNutritionValue;
}

class KnownNutritionValue extends NutritionValue {
  const KnownNutritionValue({
    required this.milliUnits,
    required super.unit,
    required super.source,
  }) : assert(milliUnits >= 0);

  final int milliUnits;
}

class UnknownNutritionValue extends NutritionValue {
  const UnknownNutritionValue({required super.unit, required super.source});
}

/// Typed nutrient values for an item or entry. Missing core nutrients are
/// normalized to unknown so that absence never looks like zero.
class NutritionFacts {
  NutritionFacts(Map<NutrientId, NutritionValue> values)
    : _values = Map.unmodifiable(_normalize(values));

  final Map<NutrientId, NutritionValue> _values;

  Map<NutrientId, NutritionValue> get values => _values;

  NutritionValue operator [](NutrientId nutrient) =>
      _values[nutrient] ??
      UnknownNutritionValue(
        unit: nutrient.canonicalUnit,
        source: NutritionValueSource.calculated,
      );

  /// A total is unknown when any contributing item is unknown. This preserves
  /// incomplete estimates instead of silently treating them as zero.
  static NutritionFacts sum(Iterable<NutritionFacts> facts) {
    final allFacts = facts.toList(growable: false);
    final nutrientIds = <NutrientId>{
      ...NutrientId.core,
      for (final item in allFacts) ...item.values.keys,
    };
    final totals = <NutrientId, NutritionValue>{};
    for (final nutrient in nutrientIds) {
      final values = allFacts.map((item) => item[nutrient]).toList();
      if (values.any((value) => value is UnknownNutritionValue)) {
        totals[nutrient] = UnknownNutritionValue(
          unit: nutrient.canonicalUnit,
          source: NutritionValueSource.calculated,
        );
      } else {
        totals[nutrient] = KnownNutritionValue(
          milliUnits: values.cast<KnownNutritionValue>().fold(
            0,
            (total, value) => total + value.milliUnits,
          ),
          unit: nutrient.canonicalUnit,
          source: NutritionValueSource.calculated,
        );
      }
    }
    return NutritionFacts(totals);
  }

  static Map<NutrientId, NutritionValue> _normalize(
    Map<NutrientId, NutritionValue> values,
  ) {
    for (final entry in values.entries) {
      if (entry.key.canonicalUnit != entry.value.unit) {
        throw ArgumentError.value(
          entry.value.unit,
          'values',
          'Nutrition value unit must match its nutrient canonical unit.',
        );
      }
    }
    return {
      for (final nutrient in NutrientId.core)
        nutrient:
            values[nutrient] ??
            UnknownNutritionValue(
              unit: nutrient.canonicalUnit,
              source: NutritionValueSource.calculated,
            ),
      ...values,
    };
  }
}
