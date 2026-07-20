import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/edit_item_page.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/application/meal_detail_controller.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class MealDetailPage extends ConsumerStatefulWidget {
  const MealDetailPage({required this.mealId, super.key});

  final String mealId;

  @override
  ConsumerState<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends ConsumerState<MealDetailPage> {
  bool _deleting = false;
  Object? _deleteError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meal = ref.watch(mealDetailProvider(widget.mealId));
    return meal.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.mealDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.mealDetailTitle)),
        body: Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(mealDetailProvider(widget.mealId)),
            child: Text(l10n.retryAction),
          ),
        ),
      ),
      data: (entry) => _MealDetailView(
        entry: entry,
        deleting: _deleting,
        deleteError: _deleteError,
        onEdit: () => Navigator.of(
          context,
        ).pushNamed(AppRoutes.mealEdit, arguments: entry.id),
        onDelete: () => _delete(entry),
        onRetryDelete: () => _delete(entry),
      ),
    );
  }

  Future<void> _delete(MealEntry entry) async {
    if (_deleting) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMealTitle),
        content: Text(l10n.deleteMealBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _deleting = true;
      _deleteError = null;
    });
    try {
      await ref.read(mealMutationsProvider).softDelete(entry);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _deleteError = Object();
      });
    }
  }
}

class _MealDetailView extends StatelessWidget {
  const _MealDetailView({
    required this.entry,
    required this.deleting,
    required this.deleteError,
    required this.onEdit,
    required this.onDelete,
    required this.onRetryDelete,
  });

  final MealEntry entry;
  final bool deleting;
  final Object? deleteError;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRetryDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final localOccurrence = entry.occurredAtUtc.add(
      Duration(minutes: entry.occurredOffsetMinutes),
    );
    final incomplete = entry.items.any(
      (item) => item.nutrition.values.values.any((value) => !value.isKnown),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mealDetailTitle),
        actions: [
          IconButton(
            key: const Key('edit-meal-button'),
            tooltip: l10n.editMealAction,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: const Key('delete-meal-button'),
            tooltip: l10n.deleteAction,
            onPressed: deleting ? null : onDelete,
            icon: deleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            entry.description?.trim().isNotEmpty == true
                ? entry.description!.trim()
                : entry.items.map((item) => item.name).join(', '),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat.yMMMMd(locale).add_Hm().format(localOccurrence)} · '
            '${l10n.revisionLabel(entry.revision)}',
          ),
          if (entry.userEdited)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                avatar: const Icon(Icons.edit, size: 18),
                label: Text(l10n.editedState),
              ),
            ),
          if (incomplete) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.incompleteDataTitle),
                subtitle: Text(l10n.mealIncompleteBody),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (entry.assumptions.isNotEmpty) ...[
            Text(
              l10n.assumptionsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...entry.assumptions.map(
              (assumption) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline),
                title: Text(assumption.description),
              ),
            ),
          ],
          Text(l10n.itemsTitle, style: Theme.of(context).textTheme.titleMedium),
          ...entry.items.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(
                  '${item.amountDescription ?? ''} · '
                  '${confidenceText(l10n, item.confidence)}',
                ),
                trailing: Text(
                  nutritionValueText(
                    context,
                    item.nutrition[NutrientId.energy],
                  ),
                ),
              ),
            ),
          ),
          Card(
            child: ExpansionTile(
              title: Text(l10n.provenanceTitle),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                ListTile(
                  title: Text(l10n.providerLabel),
                  trailing: Text(entry.provenance.providerId),
                ),
                ListTile(
                  title: Text(l10n.modelLabel),
                  trailing: Text(entry.provenance.modelId),
                ),
                ListTile(
                  title: Text(l10n.detectedLocaleLabel),
                  trailing: Text(entry.provenance.detectedLocale),
                ),
                ListTile(
                  title: Text(l10n.analyzedAtLabel),
                  trailing: Text(
                    DateFormat.yMd(
                      locale,
                    ).add_Hm().format(entry.provenance.analyzedAtUtc.toLocal()),
                  ),
                ),
                ListTile(
                  title: Text(l10n.confidenceLabel),
                  trailing: Text(confidenceText(l10n, entry.confidence)),
                ),
              ],
            ),
          ),
          if (deleteError != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(l10n.deleteFailed),
                trailing: TextButton(
                  key: const Key('retry-delete-button'),
                  onPressed: onRetryDelete,
                  child: Text(l10n.retryAction),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MealEditPage extends ConsumerStatefulWidget {
  const MealEditPage({required this.mealId, super.key});

  final String mealId;

  @override
  ConsumerState<MealEditPage> createState() => _MealEditPageState();
}

class _MealEditPageState extends ConsumerState<MealEditPage> {
  MealEditDraftController? _draft;
  bool _saving = false;
  Object? _saveError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meal = ref.watch(mealDetailProvider(widget.mealId));
    return meal.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.editMealTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.editMealTitle)),
        body: Center(
          child: FilledButton(onPressed: _retry, child: Text(l10n.retryAction)),
        ),
      ),
      data: (entry) {
        _draft ??= MealEditDraftController(entry);
        final draft = _draft!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.editMealTitle)),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _OccurrenceEditor(
                entry: draft.entry,
                onChanged: (value) =>
                    setState(() => draft.updateOccurrence(value)),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.itemsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...draft.entry.items.map(
                (item) => Card(
                  child: ListTile(
                    key: Key('edit-meal-item-${item.id}'),
                    title: Text(item.name),
                    subtitle: Text(
                      nutritionValueText(
                        context,
                        item.nutrition[NutrientId.energy],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editItem(draft, item),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final id = 'new-${DateTime.now().microsecondsSinceEpoch}';
                  setState(() => draft.addItem(id));
                  _editItem(draft, draft.entry.items.last);
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.addItemAction),
              ),
              if (_saveError != null)
                Semantics(
                  liveRegion: true,
                  child: Text(l10n.editMealSaveFailed),
                ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('save-meal-button'),
                onPressed: _saving ? null : () => _save(draft),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        _saveError == null
                            ? l10n.saveChangesAction
                            : l10n.retryAction,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _retry() => ref.invalidate(mealDetailProvider(widget.mealId));

  Future<void> _editItem(MealEditDraftController draft, MealItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .88,
        child: MealItemEditor(
          item: item,
          allowRemove: draft.entry.items.length > 1,
          onSave: (updated) {
            setState(() => draft.replaceItem(updated));
            Navigator.of(context).pop();
          },
          onRemove: () {
            setState(() => draft.removeItem(item.id));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _save(MealEditDraftController draft) async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await ref.read(mealMutationsProvider).update(draft.entry);
      if (!mounted) return;
      ref.invalidate(mealDetailProvider(widget.mealId));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = Object();
      });
    }
  }
}

class _OccurrenceEditor extends StatelessWidget {
  const _OccurrenceEditor({required this.entry, required this.onChanged});

  final MealEntry entry;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final occurrence = entry.occurredAtUtc.add(
      Duration(minutes: entry.occurredOffsetMinutes),
    );
    final label = DateFormat.yMMMMd(locale).add_Hm().format(occurrence);
    return Card(
      child: ListTile(
        title: Text(l10n.occurrenceLabel),
        subtitle: Text(label),
        trailing: TextButton(
          key: const Key('meal-occurrence-button'),
          onPressed: () => _pick(context, occurrence),
          child: Text(l10n.editOccurrenceAction),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, DateTime occurrence) async {
    final date = await showDatePicker(
      context: context,
      initialDate: occurrence,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(occurrence),
    );
    if (time == null) return;
    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}
