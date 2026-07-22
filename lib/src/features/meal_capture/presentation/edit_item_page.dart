import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/core/presentation/meal_components.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';

class EditItemPage extends ConsumerStatefulWidget {
  const EditItemPage({required this.itemId, super.key});
  final String itemId;

  @override
  ConsumerState<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends ConsumerState<EditItemPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editItemTitle)),
      body: SafeArea(
        child: MealItemEditor(
          item: _controller.state.item,
          onSave: (item) {
            _controller.save(name: item.name, nutrition: item.nutrition.values);
            Navigator.of(context).pop();
          },
          onRemove: () {
            ref
                .read(reviewControllerProvider.notifier)
                .removeItem(widget.itemId);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
