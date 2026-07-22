import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

String nutrientLabel(AppLocalizations l10n, NutrientId nutrient) =>
    switch (nutrient) {
      NutrientId.energy => l10n.nutrientEnergy,
      NutrientId.protein => l10n.nutrientProtein,
      NutrientId.carbohydrates => l10n.nutrientCarbohydrates,
      NutrientId.fat => l10n.nutrientFat,
      NutrientId.fibre => l10n.nutrientFibre,
      NutrientId.sugars => l10n.nutrientSugars,
      NutrientId.salt => l10n.nutrientSalt,
      _ => nutrient.value,
    };

String unitLabel(NutritionUnit unit) =>
    unit == NutritionUnit.grams ? 'g' : 'kcal';

String nutritionValueText(BuildContext context, NutritionValue value) {
  final l10n = AppLocalizations.of(context);
  if (value is UnknownNutritionValue) return l10n.unknownValue;
  final known = value as KnownNutritionValue;
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${NumberFormat.decimalPattern(locale).format(known.milliUnits / 1000)} ${unitLabel(known.unit)}';
}

String confidenceText(AppLocalizations l10n, MealConfidence confidence) =>
    switch (confidence) {
      MealConfidence.low => l10n.confidenceLow,
      MealConfidence.medium => l10n.confidenceMedium,
      MealConfidence.high => l10n.confidenceHigh,
    };

int? parseMilliUnits(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  final match = RegExp(r'^(\d+)(?:\.(\d{1,3}))?$').firstMatch(normalized);
  if (match == null) return null;
  final whole = int.tryParse(match.group(1)!);
  if (whole == null) return null;
  final fraction = (match.group(2) ?? '').padRight(3, '0');
  return whole * 1000 + int.parse(fraction);
}
