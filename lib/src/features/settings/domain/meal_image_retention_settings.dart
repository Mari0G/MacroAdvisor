abstract interface class MealImageRetentionSettings {
  Future<bool> isEnabled();

  Stream<bool> observeEnabled();

  Future<void> setEnabled(bool enabled);
}
