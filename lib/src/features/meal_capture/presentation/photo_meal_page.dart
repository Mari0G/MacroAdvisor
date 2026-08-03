import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';

class PhotoMealPage extends ConsumerWidget {
  const PhotoMealPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(photoControllerProvider);
    final controller = ref.read(photoControllerProvider.notifier);
    final photo = state.photo;
    if (photo == null) return const SizedBox.shrink();
    final isBusy =
        state.phase == PhotoPhase.preparing ||
        state.phase == PhotoPhase.analyzing;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && !isBusy && await _confirmDiscard(context)) {
          controller.discard();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.photoMealTitle)),
        body: SafeArea(
          child: ResponsiveContent(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Semantics(
                  label: l10n.photoPreviewLabel,
                  image: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      photo.jpegBytes,
                      fit: BoxFit.contain,
                      height: 280,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.photoPrivacyHint),
                const SizedBox(height: 8),
                Text(l10n.photoGuidanceHint),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(l10n.occurrenceLabel),
                  subtitle: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatFullDate(state.occurredAt),
                  ),
                  enabled: !isBusy,
                  onTap: isBusy
                      ? null
                      : () => _pickOccurrence(
                          context,
                          controller,
                          state.occurredAt,
                        ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _replace(context, controller),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.replacePhotoAction),
                    ),
                    TextButton.icon(
                      onPressed: isBusy
                          ? null
                          : () {
                              controller.discard();
                              Navigator.of(context).pop();
                            },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.removePhotoAction),
                    ),
                  ],
                ),
                if (state.phase == PhotoPhase.analyzing ||
                    state.phase == PhotoPhase.preparing) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 8),
                  Center(child: Text(l10n.estimatingNutrition)),
                  TextButton(
                    onPressed: state.phase == PhotoPhase.analyzing
                        ? controller.cancelAnalysis
                        : null,
                    child: Text(l10n.cancelAnalysisAction),
                  ),
                ],
                if (state.phase == PhotoPhase.failure) ...[
                  const SizedBox(height: 16),
                  _AnalysisFailure(failure: state.failure),
                  if (state.failure is MissingAnalysisCredential ||
                      state.failure is InvalidAnalysisCredential)
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.providerSettings),
                      child: Text(l10n.openProviderSettingsAction),
                    ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('analyze-photo-button'),
                  onPressed: state.canAnalyze
                      ? () async {
                          await controller.analyze(
                            Localizations.localeOf(context).toLanguageTag(),
                          );
                          if (context.mounted &&
                              ref.read(photoControllerProvider).phase ==
                                  PhotoPhase.readyForReview) {
                            Navigator.of(
                              context,
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

  Future<void> _replace(
    BuildContext context,
    PhotoController controller,
  ) async {
    final source = await showModalBottomSheet<MealPhotoSourceType>(
      context: context,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.takePhotoAction),
                onTap: () =>
                    Navigator.pop(sheetContext, MealPhotoSourceType.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.choosePhotoAction),
                onTap: () =>
                    Navigator.pop(sheetContext, MealPhotoSourceType.library),
              ),
            ],
          ),
        );
      },
    );
    if (source != null) await controller.chooseSource(source);
  }

  Future<void> _pickOccurrence(
    BuildContext context,
    PhotoController controller,
    DateTime current,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;
    controller.updateOccurredAt(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.discardPhotoTitle),
            content: Text(l10n.discardPhotoBody),
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

class _AnalysisFailure extends StatelessWidget {
  const _AnalysisFailure({required this.failure});

  final Object? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (failure) {
      MissingAnalysisCredential() ||
      InvalidAnalysisCredential() => l10n.connectionInvalidCredential,
      AnalysisOffline() => l10n.analysisOffline,
      AnalysisRateLimited() => l10n.analysisRateLimited,
      InvalidAnalysisResponse() => l10n.analysisInvalidResponse,
      AnalysisContentRejected() => l10n.analysisRejected,
      NoMealDetected() => l10n.noMealDetected,
      UnsupportedMealPhoto() => l10n.photoUnsupported,
      OversizedMealPhoto() => l10n.photoTooLarge,
      UnreadableMealPhoto() => l10n.photoUnreadable,
      _ => l10n.analysisUnavailable,
    };
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(text)),
    );
  }
}
