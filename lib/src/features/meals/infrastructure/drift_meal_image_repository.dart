import 'package:drift/drift.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_image.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_image_policy.dart';
import 'package:macro_advisor/src/features/settings/domain/meal_image_retention_settings.dart';

class DriftMealImageRepository
    implements MealImageRepository, MealImageRetentionSettings {
  DriftMealImageRepository(this._database);

  static const _settingsId = 1;

  final AppDatabase _database;

  @override
  Future<RetainedMealImage?> findByMealId(String mealId) async {
    final row = await (_database.select(
      _database.mealRetainedImages,
    )..where((image) => image.mealEntryId.equals(mealId))).getSingleOrNull();
    if (row == null) return null;
    _validate(row);
    return RetainedMealImage(
      mealId: row.mealEntryId,
      jpegBytes: row.jpegBytes,
      width: row.width,
      height: row.height,
      mimeType: row.mimeType,
    );
  }

  @override
  Future<void> removeForMeal(String mealId) async {
    await (_database.delete(
      _database.mealRetainedImages,
    )..where((image) => image.mealEntryId.equals(mealId))).go();
  }

  @override
  Future<bool> isEnabled() async {
    final row = await (_database.select(
      _database.mealImageRetentionSettings,
    )..where((setting) => setting.id.equals(_settingsId))).getSingleOrNull();
    return row?.enabled ?? true;
  }

  @override
  Stream<bool> observeEnabled() =>
      (_database.select(_database.mealImageRetentionSettings)
            ..where((setting) => setting.id.equals(_settingsId)))
          .watchSingle()
          .map((row) => row.enabled);

  @override
  Future<void> setEnabled(bool enabled) async {
    await _database.transaction(() async {
      await (_database.update(_database.mealImageRetentionSettings)
            ..where((setting) => setting.id.equals(_settingsId)))
          .write(MealImageRetentionSettingsCompanion(enabled: Value(enabled)));
      if (!enabled) {
        await _database.delete(_database.mealRetainedImages).go();
      }
    });
  }

  static void validateCandidate(RetainedMealImage image) {
    if (image.mealId.isEmpty ||
        !MealImagePolicy.accepts(
          bytes: image.jpegBytes,
          width: image.width,
          height: image.height,
          mime: image.mimeType,
        )) {
      throw const MealImagePersistenceFailure();
    }
  }

  static void _validate(MealRetainedImageRow row) {
    validateCandidate(
      RetainedMealImage(
        mealId: row.mealEntryId,
        jpegBytes: row.jpegBytes,
        width: row.width,
        height: row.height,
        mimeType: row.mimeType,
      ),
    );
  }
}

class MealImagePersistenceFailure implements Exception {
  const MealImagePersistenceFailure();
}
