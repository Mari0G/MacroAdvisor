import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:macro_advisor/src/core/infrastructure/database/tables/meal_tables.dart';

part 'app_database.g.dart';

/// The application's single local database. Feature repositories own all
/// mapping so generated Drift types do not escape this infrastructure boundary.
@DriftDatabase(
  tables: [
    MealEntries,
    MealItems,
    MealNutrientValues,
    GoalTargets,
    MealRetainedImages,
    MealImageRetentionSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'macro_advisor'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await into(mealImageRetentionSettings).insert(
        MealImageRetentionSettingsCompanion.insert(
          id: const Value(1),
          enabled: true,
        ),
      );
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(goalTargets);
      if (from < 3) {
        await migrator.createTable(mealRetainedImages);
        await migrator.createTable(mealImageRetentionSettings);
        await into(mealImageRetentionSettings).insert(
          MealImageRetentionSettingsCompanion.insert(
            id: const Value(1),
            enabled: true,
          ),
        );
      }
    },
  );
}
