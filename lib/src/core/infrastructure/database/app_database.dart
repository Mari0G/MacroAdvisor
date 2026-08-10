import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:macro_advisor/src/core/infrastructure/database/tables/meal_tables.dart';

part 'app_database.g.dart';

/// The application's single local database. Feature repositories own all
/// mapping so generated Drift types do not escape this infrastructure boundary.
@DriftDatabase(
  tables: [MealEntries, MealItems, MealNutrientValues, GoalTargets],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'macro_advisor'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(goalTargets);
    },
  );
}
