import 'package:flutter/material.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/core/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

/// Shared estimate disclosure used wherever a reviewed meal is shown.
class MealEstimateNotice extends StatelessWidget {
  const MealEstimateNotice({
    required this.confidence,
    required this.assumptions,
    super.key,
  });

  final MealConfidence confidence;
  final List<MealAssumption> assumptions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.estimateNotice),
            const SizedBox(height: 8),
            Semantics(
              label: confidenceText(l10n, confidence),
              child: Chip(label: Text(confidenceText(l10n, confidence))),
            ),
            if (assumptions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.assumptionsTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...assumptions.map((item) => Text('• ${item.description}')),
            ],
          ],
        ),
      ),
    );
  }
}

class MealTotalsCard extends StatelessWidget {
  const MealTotalsCard({required this.totals, super.key});

  final NutritionFacts totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.totalsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...NutrientId.core.map(
              (nutrient) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(nutrientLabel(l10n, nutrient)),
                trailing: Text(nutritionValueText(context, totals[nutrient])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealItemEditor extends StatefulWidget {
  const MealItemEditor({
    required this.item,
    required this.onSave,
    required this.onRemove,
    this.allowRemove = true,
    super.key,
  });

  final MealItem item;
  final ValueChanged<MealItem> onSave;
  final VoidCallback onRemove;
  final bool allowRemove;

  @override
  State<MealItemEditor> createState() => _MealItemEditorState();
}

class _MealItemEditorState extends State<MealItemEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _grams;
  late final Map<NutrientId, TextEditingController> _nutrients;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item.name);
    _amount = TextEditingController(text: widget.item.amountDescription ?? '');
    _grams = TextEditingController(
      text: widget.item.normalizedGramsMilli == null
          ? ''
          : _formatMilli(widget.item.normalizedGramsMilli!),
    );
    _nutrients = {
      for (final nutrient in NutrientId.core)
        nutrient: TextEditingController(
          text: _asInput(widget.item.nutrition[nutrient]),
        ),
    };
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _grams.dispose();
    for (final controller in _nutrients.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.itemNameLabel),
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.itemNameRequired
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amount,
            decoration: InputDecoration(labelText: l10n.itemAmountLabel),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _grams,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.itemNormalizedGramsLabel,
              helperText: unitLabel(NutritionUnit.grams),
            ),
            validator: (value) =>
                value == null ||
                    value.trim().isEmpty ||
                    parseMilliUnits(value) != null
                ? null
                : l10n.analysisInvalidResponse,
          ),
          const SizedBox(height: 16),
          ...NutrientId.core.map(
            (nutrient) => TextFormField(
              key: Key('item-nutrient-${nutrient.value}'),
              controller: _nutrients[nutrient],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: nutrientLabel(l10n, nutrient),
                helperText:
                    '${unitLabel(nutrient.canonicalUnit)} · ${l10n.unknownValue} when blank',
              ),
              validator: (value) =>
                  value == null ||
                      value.trim().isEmpty ||
                      parseMilliUnits(value) != null
                  ? null
                  : l10n.analysisInvalidResponse,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('save-item-button'),
            onPressed: _save,
            child: Text(l10n.saveChangesAction),
          ),
          if (widget.allowRemove)
            TextButton(
              onPressed: widget.onRemove,
              child: Text(l10n.removeItemAction),
            ),
        ],
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final grams = parseMilliUnits(_grams.text);
    final values = <NutrientId, NutritionValue>{
      for (final nutrient in NutrientId.core)
        nutrient: _valueFor(nutrient, _nutrients[nutrient]!.text),
    };
    widget.onSave(
      MealItem(
        id: widget.item.id,
        name: _name.text.trim(),
        amountDescription: _amount.text.trim().isEmpty
            ? null
            : _amount.text.trim(),
        normalizedGramsMilli: grams,
        confidence: widget.item.confidence,
        assumptions: widget.item.assumptions,
        nutrition: NutritionFacts(values),
      ),
    );
  }

  String _asInput(NutritionValue value) =>
      value is KnownNutritionValue ? _formatMilli(value.milliUnits) : '';

  String _formatMilli(int milliUnits) {
    final whole = milliUnits ~/ 1000;
    final fraction = (milliUnits % 1000)
        .toString()
        .padLeft(3, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    return fraction.isEmpty ? '$whole' : '$whole.$fraction';
  }

  NutritionValue _valueFor(NutrientId nutrient, String input) {
    final value = parseMilliUnits(input);
    return value == null
        ? UnknownNutritionValue(
            unit: nutrient.canonicalUnit,
            source: NutritionValueSource.userEdited,
          )
        : KnownNutritionValue(
            milliUnits: value,
            unit: nutrient.canonicalUnit,
            source: NutritionValueSource.userEdited,
          );
  }
}
