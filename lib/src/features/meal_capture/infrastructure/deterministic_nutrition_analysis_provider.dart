import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

/// Development and test provider. It is deliberately deterministic and makes
/// no network request or credential lookup.
class DeterministicNutritionAnalysisProvider
    implements NutritionAnalysisProvider {
  DeterministicNutritionAnalysisProvider(this._clock, this._idGenerator);

  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<NutritionAnalysis> analyzeText(
    NutritionAnalysisRequest request,
  ) async {
    final description = request.description.toLowerCase();
    if (description.contains('[offline]')) {
      throw const AnalysisOffline();
    }
    if (description.contains('[rate-limit]')) {
      throw const AnalysisRateLimited();
    }
    if (description.contains('[invalid]')) {
      throw const InvalidAnalysisResponse();
    }
    if (description.contains('[rejected]')) {
      throw const AnalysisContentRejected();
    }

    return NutritionAnalysis(
      provenance: MealProvenance(
        providerId: 'deterministic-fake',
        modelId: 'local-fixture-v1',
        analyzedAtUtc: _utc(_clock.now()),
        detectedLocale: request.localeTag,
      ),
      confidence: MealConfidence.medium,
      assumptions: const [
        MealAssumption(
          code: 'portion-default',
          description: 'A standard serving size was assumed.',
        ),
      ],
      warnings: const [
        AnalysisWarning(
          code: 'estimate',
          description: 'Nutrition values are estimates and can be edited.',
        ),
      ],
      items: [
        MealItem(
          id: _idGenerator.newId(),
          name: request.description,
          amountDescription: '1 serving',
          normalizedGramsMilli: 250000,
          confidence: MealConfidence.medium,
          assumptions: const [
            MealAssumption(
              code: 'portion-default',
              description: 'A standard serving size was assumed.',
            ),
          ],
          nutrition: NutritionFacts({
            NutrientId.energy: const KnownNutritionValue(
              milliUnits: 450000,
              unit: NutritionUnit.kilocalories,
              source: NutritionValueSource.providerEstimate,
            ),
            NutrientId.protein: const KnownNutritionValue(
              milliUnits: 20000,
              unit: NutritionUnit.grams,
              source: NutritionValueSource.providerEstimate,
            ),
          }),
        ),
      ],
    );
  }

  static DateTime _utc(DateTime value) => value.isUtc ? value : value.toUtc();
}
