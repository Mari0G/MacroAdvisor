import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class EditItemPage extends ConsumerStatefulWidget {
  const EditItemPage({required this.itemId, super.key});
  final String itemId;

  @override
  ConsumerState<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends ConsumerState<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final Map<NutrientId, TextEditingController> _nutrients;
  late final ItemEditController _controller;

  @override
  void initState() {
    super.initState();
    final item = ref
        .read(reviewControllerProvider)
        .items
        .where((item) => item.id == widget.itemId)
        .firstOrNull;
    if (item == null) {
      throw StateError('Item is not available for editing.');
    }
    _controller = ItemEditController(
      ItemEditState(item: item),
      ref.read(reviewControllerProvider.notifier),
    );
    _name = TextEditingController(text: item.name);
    _nutrients = {
      for (final nutrient in NutrientId.core)
        nutrient: TextEditingController(
          text: _asInput(item.nutrition[nutrient]),
        ),
    };
  }

  @override
  void dispose() {
    _name.dispose();
    for (final controller in _nutrients.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editItemTitle)),
      body: SafeArea(
        child: Form(
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
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final values = <NutrientId, NutritionValue>{
                    for (final nutrient in NutrientId.core)
                      nutrient: _valueFor(nutrient, _nutrients[nutrient]!.text),
                  };
                  if (_controller.save(name: _name.text, nutrition: values)) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(l10n.saveChangesAction),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(reviewControllerProvider.notifier)
                      .removeItem(widget.itemId);
                  Navigator.of(context).pop();
                },
                child: Text(l10n.removeItemAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _asInput(NutritionValue value) => value is KnownNutritionValue
      ? '${value.milliUnits ~/ 1000}${value.milliUnits % 1000 == 0 ? '' : '.${(value.milliUnits % 1000).toString().padLeft(3, '0').replaceFirst(RegExp(r'0+$'), '')}'}'
      : '';

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
