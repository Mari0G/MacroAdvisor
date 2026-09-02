import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/settings/domain/meal_image_retention_settings.dart';

final mealImageRetentionSettingsProvider = Provider<MealImageRetentionSettings>(
  (ref) {
    return const _DefaultMealImageRetentionSettings();
  },
);

final mealImageRetentionEnabledProvider = StreamProvider<bool>((ref) {
  return ref.watch(mealImageRetentionSettingsProvider).observeEnabled();
});

final class _DefaultMealImageRetentionSettings
    implements MealImageRetentionSettings {
  const _DefaultMealImageRetentionSettings();

  @override
  Future<bool> isEnabled() async => true;

  @override
  Stream<bool> observeEnabled() => Stream.value(true);

  @override
  Future<void> setEnabled(bool enabled) async {}
}
