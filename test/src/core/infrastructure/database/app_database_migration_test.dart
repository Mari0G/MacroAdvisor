import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/infrastructure/drift_goal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_repository.dart';

void main() {
  for (final version in [1, 2]) {
    test(
      'upgrades historical v$version to v3 without losing or backfilling data',
      () async {
        final historicalTables = [
          'meal_entries',
          'meal_items',
          'meal_nutrient_values',
          if (version == 2) 'goal_targets',
        ];
        final before = <String, List<Map<String, Object?>>>{};
        final database = AppDatabase.forTesting(
          NativeDatabase.memory(
            setup: (sqlite) {
              sqlite.execute(
                File(
                  'test/fixtures/database/schema_v$version.sql',
                ).readAsStringSync(),
              );
              sqlite.execute(_historicalMeals);
              if (version == 2) sqlite.execute(_historicalGoals);
              for (final table in historicalTables) {
                before[table] = sqlite
                    .select('SELECT * FROM $table')
                    .map((row) => Map<String, Object?>.from(row))
                    .toList();
              }
              expect(sqlite.userVersion, version);
            },
          ),
        );
        final fresh = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);
        addTearDown(fresh.close);

        // The first query must run the real onUpgrade path, not onCreate.
        final settings = await database
            .select(database.mealImageRetentionSettings)
            .get();
        expect(settings, hasLength(1));
        expect(settings.single.id, 1);
        expect(settings.single.enabled, isTrue);
        expect(
          await database.select(database.mealRetainedImages).get(),
          isEmpty,
        );
        for (final table in historicalTables) {
          expect(
            await _rows(database, 'SELECT * FROM $table'),
            before[table],
            reason: '$table must survive v$version -> v3 unchanged',
          );
        }
        if (version == 1) {
          expect(await database.select(database.goalTargets).get(), isEmpty);
        }
        final meals = DriftMealRepository(database, _Clock(), _Ids());
        final active = (await meals.findById('synthetic-active'))!;
        expect(active.description, 'Synthetic fixture meal');
        expect(active.userEdited, isTrue);
        expect(active.revision, 4);
        expect(active.assumptions.single.code, 'synthetic');
        expect(active.assumptions.single.description, 'Synthetic assumption');
        expect(active.items.single.name, 'Synthetic oats');
        expect(
          (active.items.single.nutrition[NutrientId.energy]
                  as KnownNutritionValue)
              .milliUnits,
          123456,
        );
        expect(
          active.items.single.nutrition[NutrientId.protein].source,
          NutritionValueSource.userEdited,
        );
        expect(await meals.findById('synthetic-deleted'), isNull);
        final deleted = (await meals.findById(
          'synthetic-deleted',
          includeDeleted: true,
        ))!;
        expect(deleted.deletedAtUtc, isNotNull);
        expect(deleted.items.single.assumptions.single.code, 'synthetic');
        expect(
          deleted.items.single.nutrition[NutrientId.protein],
          isA<UnknownNutritionValue>(),
        );
        final goals = await DriftGoalRepository(database).read();
        if (version == 1) {
          expect(goals.active, isEmpty);
        } else {
          expect(
            goals[NutrientId.energy],
            const RangeGoalTarget(1800000, 2200000),
          );
          expect(goals[NutrientId.protein], const MinimumGoalTarget(90000));
          expect(goals[NutrientId.salt], const MaximumGoalTarget(6000));
        }
        expect(
          (await _rows(database, 'PRAGMA user_version')).single['user_version'],
          3,
        );
        expect(await _rows(database, 'PRAGMA foreign_key_check'), isEmpty);

        // Compare columns, nullability, defaults, keys and references against a
        // newly created v3 database. Historical fixtures never use current tables.
        const tables = [
          'goal_targets',
          'meal_entries',
          'meal_image_retention_settings',
          'meal_items',
          'meal_nutrient_values',
          'meal_retained_images',
        ];
        expect(
          await _rows(database, _tableNames),
          await _rows(fresh, _tableNames),
        );
        for (final table in tables) {
          for (final pragma in [
            'table_info',
            'foreign_key_list',
            'index_list',
          ]) {
            expect(
              await _rows(database, 'PRAGMA $pragma($table)'),
              await _rows(fresh, 'PRAGMA $pragma($table)'),
              reason: '$table $pragma after v$version -> v3',
            );
          }
        }
      },
    );
  }
}

Future<List<Map<String, Object?>>> _rows(
  AppDatabase database,
  String sql,
) async =>
    (await database.customSelect(sql).get()).map((row) => row.data).toList();

const _tableNames = '''
SELECT name FROM sqlite_master
WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name
''';

// Entirely synthetic meals cover edited, soft-deleted and nullable old values.
const _historicalMeals = '''
INSERT INTO meal_entries VALUES
('synthetic-active', 1700000000, 60, 'Synthetic fixture meal', 'fixture',
 'fixture-model', 1700000001, 'de', 'medium', '[{"code":"synthetic","description":"Synthetic assumption"}]',
 1, 1700000002, 1700000003, NULL, 4),
('synthetic-deleted', 1700000100, -120, NULL, 'fixture', 'fixture-model',
 1700000101, 'en', 'low', '[]', 0, 1700000102, 1700000103, 1700000104, 2);
INSERT INTO meal_items VALUES
('synthetic-item-1', 'synthetic-active', 0, 'Synthetic oats', 'One serving',
 125000, 'medium', '[]'),
('synthetic-item-2', 'synthetic-deleted', 0, 'Synthetic fruit', NULL,
 NULL, 'low', '[{"code":"synthetic","description":"Synthetic item assumption"}]');
INSERT INTO meal_nutrient_values VALUES
('synthetic-item-1', 'energy', 'kilocalories', 123456, 'providerEstimate'),
('synthetic-item-1', 'protein', 'grams', 7890, 'userEdited'),
('synthetic-item-2', 'protein', 'grams', NULL, 'providerEstimate');
''';

const _historicalGoals = '''
INSERT INTO goal_targets VALUES
('energy', 'kilocalories', 'range', 1800000, 2200000),
('protein', 'grams', 'minimum', 90000, NULL),
('salt', 'grams', 'maximum', NULL, 6000);
''';

class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 9, 5);
}

class _Ids implements IdGenerator {
  @override
  String newId() => throw StateError('Migration reads must not create IDs');
}
