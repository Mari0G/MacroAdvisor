import 'package:drift/drift.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/settings/domain/appearance_settings.dart';

final class DriftAppearanceSettings implements AppearanceSettings {
  const DriftAppearanceSettings(this._database);

  final AppDatabase _database;

  @override
  Future<String?> readPaletteId() async => (await (_database.select(
    _database.appearanceSettings,
  )..where((row) => row.id.equals(1))).getSingleOrNull())?.paletteId;

  @override
  Stream<String?> observePaletteId() =>
      (_database.select(_database.appearanceSettings)
            ..where((row) => row.id.equals(1)))
          .watchSingleOrNull()
          .map((row) => row?.paletteId);

  @override
  Future<void> savePaletteId(String id) async {
    await _database
        .into(_database.appearanceSettings)
        .insertOnConflictUpdate(
          AppearanceSettingsCompanion.insert(id: const Value(1), paletteId: id),
        );
  }
}
