import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class ReviewEstimatePage extends ConsumerWidget {
  const ReviewEstimatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(reviewControllerProvider);
    final controller = ref.read(reviewControllerProvider.notifier);
    ref.listen(reviewControllerProvider, (_, next) {
      if (next.phase == ReviewPhase.saved) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.mealSaved)));
        ref.read(descriptionControllerProvider.notifier).reset();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.today, (_) => false);
      }
    });
    if (state.phase == ReviewPhase.unavailable) {
      return Scaffold(body: Center(child: Text(l10n.analysisUnavailable)));
    }
    return PopScope(
      canPop: state.phase == ReviewPhase.saved,
      onPopInvokedWithResult: (didPop, _) async {
        final shouldDiscard = !didPop && await _confirmDiscard(context);
        if (shouldDiscard && context.mounted) {
          ref.read(descriptionControllerProvider.notifier).reset();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.reviewEstimateTitle)),
        body: SafeArea(
          child: ResponsiveContent(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.estimateNotice),
                              const SizedBox(height: 8),
                              Semantics(
                                label: confidenceText(
                                  l10n,
                                  state.analysis!.confidence,
                                ),
                                child: Chip(
                                  label: Text(
                                    confidenceText(
                                      l10n,
                                      state.analysis!.confidence,
                                    ),
                                  ),
                                ),
                              ),
                              if (state.analysis!.assumptions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  l10n.assumptionsTitle,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                ...state.analysis!.assumptions.map(
                                  (item) => Text('• ${item.description}'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (state.analysis!.warnings.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.warningsTitle,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                ...state.analysis!.warnings.map(
                                  (warning) => Text(warning.description),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ListTile(
                        title: Text(l10n.occurrenceLabel),
                        subtitle: Text(
                          MaterialLocalizations.of(
                            context,
                          ).formatFullDate(state.occurredAt!),
                        ),
                      ),
                      ...state.items.map(
                        (item) => Card(
                          child: ListTile(
                            key: Key('review-item-${item.id}'),
                            title: Text(item.name),
                            subtitle: Text(_itemSummary(context, item)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: state.phase == ReviewPhase.reviewing
                                ? () => Navigator.of(context).pushNamed(
                                    AppRoutes.editMealItem,
                                    arguments: item.id,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: state.phase == ReviewPhase.reviewing
                            ? () {
                                final item = controller.addItem();
                                Navigator.of(context).pushNamed(
                                  AppRoutes.editMealItem,
                                  arguments: item.id,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addItemAction),
                      ),
                      _TotalsCard(totals: state.totals),
                      if (state.phase == ReviewPhase.saveFailure)
                        Semantics(
                          liveRegion: true,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(l10n.saveFailed),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: FilledButton(
                    key: const Key('confirm-save-button'),
                    onPressed: state.canSave ? controller.save : null,
                    child: state.phase == ReviewPhase.saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            state.phase == ReviewPhase.saveFailure
                                ? l10n.retryAction
                                : l10n.confirmAndSaveAction,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _itemSummary(BuildContext context, MealItem item) {
    final protein = item.nutrition[NutrientId.protein];
    return '${item.amountDescription ?? ''} · ${nutritionValueText(context, protein)}';
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.discardDraftTitle),
            content: Text(l10n.discardDraftBody),
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
        ) ??
        false;
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.totals});
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
