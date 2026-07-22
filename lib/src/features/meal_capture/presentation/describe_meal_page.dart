import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';

class DescribeMealPage extends ConsumerStatefulWidget {
  const DescribeMealPage({super.key});

  @override
  ConsumerState<DescribeMealPage> createState() => _DescribeMealPageState();
}

class _DescribeMealPageState extends ConsumerState<DescribeMealPage> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(descriptionControllerProvider);
    final controller = ref.read(descriptionControllerProvider.notifier);
    if (_textController.text != state.description) {
      _textController.text = state.description;
    }

    return PopScope(
      canPop: !state.hasDraft && state.phase != DescriptionPhase.analyzing,
      onPopInvokedWithResult: (didPop, _) async {
        final shouldDiscard = !didPop && await _confirmDiscard(context);
        if (shouldDiscard && mounted) {
          controller.reset();
          Navigator.of(this.context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.describeMealTitle)),
        body: SafeArea(
          child: ResponsiveContent(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Text(l10n.descriptionPrivacyHint),
                const SizedBox(height: 20),
                TextField(
                  key: const Key('meal-description-field'),
                  controller: _textController,
                  enabled: state.phase != DescriptionPhase.analyzing,
                  minLines: 4,
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  onChanged: controller.updateDescription,
                  decoration: InputDecoration(
                    labelText: l10n.mealDescriptionLabel,
                    helperText: l10n.mealDescriptionHelper,
                    suffixIcon: state.description.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.cancelAction,
                            onPressed: () => controller.updateDescription(''),
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('${state.description.length}'),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(l10n.occurrenceLabel),
                  subtitle: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatFullDate(state.occurredAt),
                  ),
                  leading: const Icon(Icons.schedule_outlined),
                ),
                if (state.phase == DescriptionPhase.analyzing) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 12),
                  Center(child: Text(l10n.estimatingNutrition)),
                  Center(child: Text(l10n.analysisMayTakeMoment)),
                  TextButton(
                    onPressed: controller.cancelAnalysis,
                    child: Text(l10n.cancelAnalysisAction),
                  ),
                ],
                if (state.phase == DescriptionPhase.failure)
                  _FailureCard(failure: state.failure!),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('analyze-meal-button'),
                  onPressed: state.canSubmit
                      ? () async {
                          await controller.analyze(
                            Localizations.localeOf(context).toLanguageTag(),
                          );
                          if (mounted &&
                              ref.read(descriptionControllerProvider).phase ==
                                  DescriptionPhase.readyForReview) {
                            Navigator.of(
                              this.context,
                            ).pushReplacementNamed(AppRoutes.reviewMeal);
                          }
                        }
                      : null,
                  child: Text(l10n.analyzeEstimateAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

class _FailureCard extends ConsumerWidget {
  const _FailureCard({required this.failure});

  final NutritionAnalysisFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = switch (failure) {
      MissingAnalysisCredential() ||
      InvalidAnalysisCredential() => l10n.connectionInvalidCredential,
      AnalysisOffline() => l10n.analysisOffline,
      AnalysisRateLimited() => l10n.analysisRateLimited,
      InvalidAnalysisResponse() => l10n.analysisInvalidResponse,
      AnalysisContentRejected() => l10n.analysisRejected,
      _ => l10n.analysisUnavailable,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            if (failure is MissingAnalysisCredential ||
                failure is InvalidAnalysisCredential)
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.providerSettings),
                child: Text(l10n.openProviderSettingsAction),
              ),
          ],
        ),
      ),
    );
  }
}
