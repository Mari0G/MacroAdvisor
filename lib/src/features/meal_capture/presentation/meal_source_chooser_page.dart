import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';

class MealSourceChooserPage extends ConsumerWidget {
  const MealSourceChooserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(photoControllerProvider);
    final photoController = ref.read(photoControllerProvider.notifier);
    final isPreparing = state.phase == PhotoPhase.preparing;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordMealAction)),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              Text(l10n.chooseMealInputHint),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('describe-meal-source'),
                onPressed: isPreparing
                    ? null
                    : () {
                        ref.read(photoControllerProvider.notifier).discard();
                        ref
                            .read(descriptionControllerProvider.notifier)
                            .reset();
                        ref.invalidate(reviewControllerProvider);
                        Navigator.of(context).pushNamed(AppRoutes.describeMeal);
                      },
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.describeMealSourceAction),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('take-photo-source'),
                onPressed: isPreparing
                    ? null
                    : () => _selectPhoto(
                        context,
                        ref,
                        photoController,
                        MealPhotoSourceType.camera,
                      ),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(l10n.takePhotoAction),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('choose-photo-source'),
                onPressed: isPreparing
                    ? null
                    : () => _selectPhoto(
                        context,
                        ref,
                        photoController,
                        MealPhotoSourceType.library,
                      ),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.choosePhotoAction),
              ),
              if (isPreparing) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              if (state.phase == PhotoPhase.failure && state.photo == null) ...[
                const SizedBox(height: 24),
                _PhotoFailure(failure: state.failure),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectPhoto(
    BuildContext context,
    WidgetRef ref,
    PhotoController controller,
    MealPhotoSourceType source,
  ) async {
    ref.invalidate(reviewControllerProvider);
    await controller.chooseSource(source);
    if (context.mounted && ref.read(photoControllerProvider).photo != null) {
      await Navigator.of(context).pushNamed(AppRoutes.photoMeal);
    }
  }
}

class _PhotoFailure extends ConsumerWidget {
  const _PhotoFailure({required this.failure});

  final Object? failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = switch (failure) {
      UnsupportedMealPhoto() => l10n.photoUnsupported,
      OversizedMealPhoto() => l10n.photoTooLarge,
      UnreadableMealPhoto() => l10n.photoUnreadable,
      PhotoPermissionDenied() => l10n.photoPermissionDenied,
      _ => l10n.photoUnavailable,
    };
    final permanentlyDenied =
        failure is PhotoPermissionDenied &&
        (failure as PhotoPermissionDenied).permanentlyDenied;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            if (permanentlyDenied)
              TextButton(
                onPressed: () async {
                  final source = ref.read(mealPhotoSourceProvider);
                  if (source is MealPhotoSettingsOpener) {
                    await (source as MealPhotoSettingsOpener).openAppSettings();
                  }
                },
                child: Text(l10n.openSettingsAction),
              ),
          ],
        ),
      ),
    );
  }
}
