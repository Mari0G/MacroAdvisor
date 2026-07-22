import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/goals/application/goal_settings_controller.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

enum _GoalTargetKind { off, minimum, maximum, range }

class GoalSettingsPage extends ConsumerStatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  ConsumerState<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends ConsumerState<GoalSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _kinds = <NutrientId, _GoalTargetKind>{};
  final _minimumControllers = <NutrientId, TextEditingController>{};
  final _maximumControllers = <NutrientId, TextEditingController>{};
  var _initialized = false;
  var _dirty = false;
  NutrientId? _rangeError;

  @override
  void initState() {
    super.initState();
    for (final nutrient in NutrientId.core) {
      _kinds[nutrient] = _GoalTargetKind.off;
      _minimumControllers[nutrient] = TextEditingController();
      _maximumControllers[nutrient] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _minimumControllers.values) {
      controller.dispose();
    }
    for (final controller in _maximumControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(goalSettingsControllerProvider);
    if (state.phase == GoalSettingsPhase.ready && !_initialized) {
      _applyGoals(state.goals!);
      _initialized = true;
    }
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.goalSettingsTitle)),
        bottomNavigationBar:
            state.phase == GoalSettingsPhase.ready ||
                state.phase == GoalSettingsPhase.saving
            ? SafeArea(
                minimum: const EdgeInsets.all(16),
                child: FilledButton(
                  key: const Key('save-goals-button'),
                  onPressed: state.isBusy ? null : _save,
                  child: state.phase == GoalSettingsPhase.saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                      : Text(l10n.saveGoalsAction),
                ),
              )
            : null,
        body: SafeArea(
          child: ResponsiveContent(
            child: switch (state.phase) {
              GoalSettingsPhase.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              GoalSettingsPhase.failure => _Failure(
                onRetry: ref
                    .read(goalSettingsControllerProvider.notifier)
                    .retry,
              ),
              _ => Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  children: [
                    Text(l10n.goalSettingsBody),
                    const SizedBox(height: 16),
                    for (final nutrient in NutrientId.core)
                      _GoalRow(
                        nutrient: nutrient,
                        kind: _kinds[nutrient]!,
                        minimumController: _minimumControllers[nutrient]!,
                        maximumController: _maximumControllers[nutrient]!,
                        onKindChanged: (kind) => setState(() {
                          _kinds[nutrient] = kind;
                          _dirty = true;
                        }),
                        rangeError: _rangeError == nutrient,
                        onChanged: () => setState(() {
                          _dirty = true;
                          _rangeError = null;
                        }),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            },
          ),
        ),
      ),
    );
  }

  void _applyGoals(GoalSet goals) {
    for (final nutrient in NutrientId.core) {
      final target = goals[nutrient];
      _kinds[nutrient] = switch (target) {
        null => _GoalTargetKind.off,
        MinimumGoalTarget() => _GoalTargetKind.minimum,
        MaximumGoalTarget() => _GoalTargetKind.maximum,
        RangeGoalTarget() => _GoalTargetKind.range,
      };
      _minimumControllers[nutrient]!.text = _display(
        context,
        target?.minimumMilliUnits,
      );
      _maximumControllers[nutrient]!.text = _display(
        context,
        target?.maximumMilliUnits,
      );
    }
  }

  String _display(BuildContext context, int? value) => value == null
      ? ''
      : NumberFormat.decimalPattern(
          Localizations.localeOf(context).toLanguageTag(),
        ).format(value / 1000);

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final targets = <NutrientId, GoalTarget>{};
    for (final nutrient in NutrientId.core) {
      final minimum = parseMilliUnits(_minimumControllers[nutrient]!.text);
      final maximum = parseMilliUnits(_maximumControllers[nutrient]!.text);
      switch (_kinds[nutrient]!) {
        case _GoalTargetKind.off:
          break;
        case _GoalTargetKind.minimum:
          targets[nutrient] = MinimumGoalTarget(minimum!);
        case _GoalTargetKind.maximum:
          targets[nutrient] = MaximumGoalTarget(maximum!);
        case _GoalTargetKind.range:
          if (minimum! > maximum!) {
            setState(() => _rangeError = nutrient);
            return;
          }
          targets[nutrient] = RangeGoalTarget(minimum, maximum);
      }
    }
    await ref
        .read(goalSettingsControllerProvider.notifier)
        .save(GoalSet(targets));
    if (!mounted) return;
    if (ref.read(goalSettingsControllerProvider).phase ==
        GoalSettingsPhase.ready) {
      setState(() => _dirty = false);
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardGoalChangesTitle),
        content: Text(l10n.discardGoalChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.discardAction),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() => _dirty = false);
      Navigator.of(context).pop();
    }
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.nutrient,
    required this.kind,
    required this.minimumController,
    required this.maximumController,
    required this.onKindChanged,
    required this.onChanged,
    required this.rangeError,
  });

  final NutrientId nutrient;
  final _GoalTargetKind kind;
  final TextEditingController minimumController;
  final TextEditingController maximumController;
  final ValueChanged<_GoalTargetKind> onKindChanged;
  final VoidCallback onChanged;
  final bool rangeError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unit = unitLabel(nutrient.canonicalUnit);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              nutrientLabel(l10n, nutrient),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<_GoalTargetKind>(
              key: ValueKey('goal-target-${nutrient.value}'),
              initialValue: kind,
              decoration: InputDecoration(labelText: l10n.goalTargetTypeLabel),
              items: [
                DropdownMenuItem(
                  value: _GoalTargetKind.off,
                  child: Text(l10n.goalTargetOff),
                ),
                DropdownMenuItem(
                  value: _GoalTargetKind.minimum,
                  child: Text(l10n.goalTargetMinimum),
                ),
                DropdownMenuItem(
                  value: _GoalTargetKind.maximum,
                  child: Text(l10n.goalTargetMaximum),
                ),
                DropdownMenuItem(
                  value: _GoalTargetKind.range,
                  child: Text(l10n.goalTargetRange),
                ),
              ],
              onChanged: (value) => onKindChanged(value!),
            ),
            if (kind == _GoalTargetKind.minimum ||
                kind == _GoalTargetKind.range) ...[
              const SizedBox(height: 12),
              _GoalNumberField(
                controller: minimumController,
                label: l10n.goalMinimumField(unit),
                onChanged: onChanged,
              ),
            ],
            if (kind == _GoalTargetKind.maximum ||
                kind == _GoalTargetKind.range) ...[
              const SizedBox(height: 12),
              _GoalNumberField(
                controller: maximumController,
                label: l10n.goalMaximumField(unit),
                onChanged: onChanged,
              ),
            ],
            if (rangeError) ...[
              const SizedBox(height: 8),
              Text(
                l10n.goalRangeInvalid,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalNumberField extends StatelessWidget {
  const _GoalNumberField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => onChanged(),
      validator: (value) =>
          parseMilliUnits(value ?? '') == null ? l10n.goalValueInvalid : null,
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: FilledButton(onPressed: onRetry, child: Text(l10n.retryAction)),
    );
  }
}
