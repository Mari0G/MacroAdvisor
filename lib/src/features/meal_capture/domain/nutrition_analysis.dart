import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';

/// A provider-neutral, validated estimate. Provider SDK DTOs and credentials
/// never cross this boundary.
class NutritionAnalysis {
  NutritionAnalysis({
    required this.provenance,
    required List<MealItem> items,
    required this.confidence,
    List<MealAssumption> assumptions = const [],
    List<AnalysisWarning> warnings = const [],
  }) : assert(items.isNotEmpty),
       items = List.unmodifiable(items),
       assumptions = List.unmodifiable(assumptions),
       warnings = List.unmodifiable(warnings);

  final MealProvenance provenance;
  final List<MealItem> items;
  final MealConfidence confidence;
  final List<MealAssumption> assumptions;
  final List<AnalysisWarning> warnings;
}

class AnalysisWarning {
  const AnalysisWarning({required this.code, required this.description});

  final String code;
  final String description;
}

class NutritionAnalysisRequest {
  const NutritionAnalysisRequest({
    required this.description,
    required this.localeTag,
  }) : assert(description != ''),
       assert(localeTag != '');

  final String description;
  final String localeTag;
}

abstract interface class NutritionAnalysisProvider {
  Future<NutritionAnalysis> analyzeText(NutritionAnalysisRequest request);
}

sealed class NutritionAnalysisFailure implements Exception {
  const NutritionAnalysisFailure();
}

final class MissingAnalysisCredential extends NutritionAnalysisFailure {
  const MissingAnalysisCredential();
}

final class InvalidAnalysisCredential extends NutritionAnalysisFailure {
  const InvalidAnalysisCredential();
}

final class AnalysisOffline extends NutritionAnalysisFailure {
  const AnalysisOffline();
}

final class AnalysisTimedOut extends NutritionAnalysisFailure {
  const AnalysisTimedOut();
}

final class AnalysisRateLimited extends NutritionAnalysisFailure {
  const AnalysisRateLimited();
}

final class InvalidAnalysisResponse extends NutritionAnalysisFailure {
  const InvalidAnalysisResponse();
}

final class AnalysisContentRejected extends NutritionAnalysisFailure {
  const AnalysisContentRejected();
}

final class UnknownAnalysisFailure extends NutritionAnalysisFailure {
  const UnknownAnalysisFailure();
}
