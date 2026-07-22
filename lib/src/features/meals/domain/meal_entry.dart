import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

enum MealConfidence { low, medium, high }

class MealAssumption {
  const MealAssumption({required this.code, required this.description});

  final String code;
  final String description;
}

class MealProvenance {
  MealProvenance({
    required this.providerId,
    required this.modelId,
    required this.analyzedAtUtc,
    required this.detectedLocale,
  }) : assert(providerId != ''),
       assert(modelId != ''),
       assert(analyzedAtUtc.isUtc),
       assert(detectedLocale != '');

  final String providerId;
  final String modelId;
  final DateTime analyzedAtUtc;
  final String detectedLocale;
}

class MealItem {
  MealItem({
    required this.id,
    required this.name,
    required this.nutrition,
    required this.confidence,
    this.amountDescription,
    this.normalizedGramsMilli,
    List<MealAssumption> assumptions = const [],
  }) : assert(id != ''),
       assert(name != ''),
       assert(normalizedGramsMilli == null || normalizedGramsMilli >= 0),
       assumptions = List.unmodifiable(assumptions);

  final String id;
  final String name;
  final String? amountDescription;
  final int? normalizedGramsMilli;
  final NutritionFacts nutrition;
  final MealConfidence confidence;
  final List<MealAssumption> assumptions;
}

class MealEntryDraft {
  MealEntryDraft({
    required this.occurredAtUtc,
    required this.occurredOffsetMinutes,
    required List<MealItem> items,
    required this.provenance,
    this.confirmationId,
    this.description,
    this.userEdited = false,
    this.confidence = MealConfidence.medium,
    List<MealAssumption> assumptions = const [],
  }) : assert(occurredAtUtc.isUtc),
       assert(occurredOffsetMinutes >= -840 && occurredOffsetMinutes <= 840),
       assert(items.isNotEmpty),
       items = List.unmodifiable(items),
       assumptions = List.unmodifiable(assumptions);

  final DateTime occurredAtUtc;
  final int occurredOffsetMinutes;
  final String? description;
  final List<MealItem> items;
  final MealProvenance provenance;

  /// A stable client-side confirmation identifier makes a retried save safe.
  final String? confirmationId;
  final bool userEdited;
  final MealConfidence confidence;
  final List<MealAssumption> assumptions;
}

class MealEntry extends MealEntryDraft {
  MealEntry({
    required this.id,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.revision,
    required super.occurredAtUtc,
    required super.occurredOffsetMinutes,
    required super.items,
    required super.provenance,
    super.description,
    super.userEdited,
    super.confidence,
    super.assumptions,
    this.deletedAtUtc,
  }) : assert(id != ''),
       assert(createdAtUtc.isUtc),
       assert(updatedAtUtc.isUtc),
       assert(deletedAtUtc == null || deletedAtUtc.isUtc),
       assert(revision >= 0);

  final String id;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? deletedAtUtc;
  final int revision;

  NutritionFacts get totals =>
      NutritionFacts.sum(items.map((item) => item.nutrition));

  bool occursOnLocalDay(DateTime localDay) {
    final localOccurrence = occurredAtUtc.add(
      Duration(minutes: occurredOffsetMinutes),
    );
    return localOccurrence.year == localDay.year &&
        localOccurrence.month == localDay.month &&
        localOccurrence.day == localDay.day;
  }
}
