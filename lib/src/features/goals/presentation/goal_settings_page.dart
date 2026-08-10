import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/goals/application/goal_settings_controller.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class GoalSettingsPage extends ConsumerStatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  ConsumerState<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends ConsumerState<GoalSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(goalSettingsControllerProvider);
    return state.when(
      loading: () =>
          _shell(context, const Center(child: CircularProgressIndicator())),
      error: (error, _) => _shell(
        context,
        Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(goalSettingsControllerProvider),
            child: Text(AppLocalizations.of(context).retryAction),
          ),
        ),
      ),
      data: (editor) => _editor(context, editor),
    );
  }

  Widget _editor(BuildContext context, GoalEditorState editor) {
    final l10n = AppLocalizations.of(context);
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave(context, editor);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.goalSettingsTitle),
          leading: BackButton(onPressed: () => _leave(context, editor)),
        ),
        body: SafeArea(
          child: ResponsiveContent(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.goalsSectionBody),
                    const SizedBox(height: 16),
                    for (final nutrient in NutrientId.core) ...[
                      _GoalNutrientRow(
                        nutrient: nutrient,
                        target: editor.goals[nutrient],
                        minimumController: _controller(
                          nutrient,
                          'minimum',
                          editor.goals[nutrient].minimumMilliUnits,
                        ),
                        maximumController: _controller(
                          nutrient,
                          'maximum',
                          editor.goals[nutrient].maximumMilliUnits,
                        ),
                        onTargetChanged: (target) => ref
                            .read(goalSettingsControllerProvider.notifier)
                            .setTarget(nutrient, target),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (editor.failure != null)
                      Semantics(
                        liveRegion: true,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(l10n.goalSaveFailed),
                        ),
                      ),
                    FilledButton(
                      key: const Key('save-goals-button'),
                      onPressed: editor.isSaving ? null : () => _save(editor),
                      child: editor.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            )
                          : Text(l10n.goalSaveAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shell(BuildContext context, Widget body) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).goalSettingsTitle)),
    body: SafeArea(child: body),
  );

  TextEditingController _controller(
    NutrientId nutrient,
    String bound,
    int? milliUnits,
  ) {
    final key = '${nutrient.value}-$bound';
    return _fields.putIfAbsent(
      key,
      () => TextEditingController(
        text: milliUnits == null ? '' : _decimalText(milliUnits),
      ),
    );
  }

  Future<void> _save(GoalEditorState editor) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      final saved = await ref
          .read(goalSettingsControllerProvider.notifier)
          .save();
      if (saved && mounted) Navigator.of(context).pop();
    } catch (_) {
      // The controller keeps the draft and exposes a localized save failure.
    }
  }

  Future<void> _leave(BuildContext context, GoalEditorState editor) async {
    if (!editor.isDirty) {
      Navigator.of(context).pop();
      return;
    }
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardGoalChangesTitle),
        content: Text(l10n.discardGoalChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discardAction),
          ),
        ],
      ),
    );
    if (discard == true && context.mounted) Navigator.of(context).pop();
  }

  String _decimalText(int milliUnits) {
    final whole = milliUnits ~/ 1000;
    final fraction = (milliUnits % 1000).toString().padLeft(3, '0');
    return fraction == '000'
        ? '$whole'
        : '$whole.$fraction'.replaceFirst(RegExp(r'0+$'), '');
  }
}

class _GoalNutrientRow extends StatelessWidget {
  const _GoalNutrientRow({
    required this.nutrient,
    required this.target,
    required this.minimumController,
    required this.maximumController,
    required this.onTargetChanged,
  });

  final NutrientId nutrient;
  final GoalTarget target;
  final TextEditingController minimumController;
  final TextEditingController maximumController;
  final ValueChanged<GoalTarget> onTargetChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kind = target.kind;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    nutrientLabel(l10n, nutrient),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(unitLabel(nutrient.canonicalUnit)),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.goalTypeLabel),
            const SizedBox(height: 8),
            SegmentedButton<GoalTargetKind>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: GoalTargetKind.off,
                  label: Text(l10n.goalTypeOff),
                ),
                ButtonSegment(
                  value: GoalTargetKind.minimum,
                  label: Text(l10n.goalTypeMinimum),
                ),
                ButtonSegment(
                  value: GoalTargetKind.maximum,
                  label: Text(l10n.goalTypeMaximum),
                ),
                ButtonSegment(
                  value: GoalTargetKind.range,
                  label: Text(l10n.goalTypeRange),
                ),
              ],
              selected: {kind},
              onSelectionChanged: (selection) {
                final nextKind = selection.first;
                final minimum = parseMilliUnits(minimumController.text) ?? 0;
                final maximum =
                    parseMilliUnits(maximumController.text) ?? minimum;
                final validMaximum = maximum < minimum ? minimum : maximum;
                onTargetChanged(
                  GoalTarget.fromValues(
                    nextKind,
                    minimumMilliUnits: minimum,
                    maximumMilliUnits: validMaximum,
                  ),
                );
              },
            ),
            if (kind != GoalTargetKind.off) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (kind == GoalTargetKind.minimum ||
                      kind == GoalTargetKind.range)
                    _valueField(
                      context,
                      controller: minimumController,
                      label: l10n.goalMinimumLabel,
                      onChanged: () => _update(context),
                    ),
                  if (kind == GoalTargetKind.maximum ||
                      kind == GoalTargetKind.range)
                    _valueField(
                      context,
                      controller: maximumController,
                      label: l10n.goalMaximumLabel,
                      onChanged: () => _update(context),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _valueField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required VoidCallback onChanged,
  }) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 180,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final parsed = parseMilliUnits(value ?? '');
          if (parsed == null) return l10n.goalValueInvalid;
          if (target.kind == GoalTargetKind.range) {
            final minimum = parseMilliUnits(minimumController.text);
            final maximum = parseMilliUnits(maximumController.text);
            if (minimum != null && maximum != null && minimum > maximum) {
              return l10n.goalRangeInvalid;
            }
          }
          return null;
        },
        onChanged: (_) => onChanged(),
      ),
    );
  }

  void _update(BuildContext context) {
    final minimum = parseMilliUnits(minimumController.text) ?? 0;
    final maximum = parseMilliUnits(maximumController.text) ?? minimum;
    final validMaximum = maximum < minimum ? minimum : maximum;
    onTargetChanged(
      GoalTarget.fromValues(
        target.kind,
        minimumMilliUnits: minimum,
        maximumMilliUnits: validMaximum,
      ),
    );
  }
}
