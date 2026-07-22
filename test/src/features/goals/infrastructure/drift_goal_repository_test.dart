import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/infrastructure/drift_goal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AppDatabase database;
  late DriftGoalRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftGoalRepository(database);
  });

  tearDown(() => database.close());

  test('observes and atomically replaces the complete goal set', () async {
    final first = GoalSet({
      NutrientId.protein: const MinimumGoalTarget(30000),
      NutrientId.energy: const RangeGoalTarget(1800000, 2200000),
    });
    await repository.save(first);

    final stored = await repository.observe().first;
    expect(stored[NutrientId.protein], isA<MinimumGoalTarget>());
    expect(stored[NutrientId.energy], isA<RangeGoalTarget>());

    await repository.save(
      GoalSet({NutrientId.fibre: const MaximumGoalTarget(30000)}),
    );
    final replaced = await repository.observe().first;
    expect(replaced.targets.keys, [NutrientId.fibre]);
    expect(
      (replaced[NutrientId.fibre] as MaximumGoalTarget).maximumMilliUnits,
      30000,
    );
  });

  test(
    'migrates a version 1 meal database to goal targets without data loss',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'macro_goals_v1_',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}goals.sqlite',
      );
      final legacy = sqlite3.open(file.path);
      legacy.execute('''
      CREATE TABLE meal_entries (
        id TEXT NOT NULL PRIMARY KEY,
        occurred_at_utc INTEGER NOT NULL,
        occurred_offset_minutes INTEGER NOT NULL,
        description TEXT,
        provider_id TEXT NOT NULL,
        model_id TEXT NOT NULL,
        analyzed_at_utc INTEGER NOT NULL,
        detected_locale TEXT NOT NULL,
        confidence TEXT NOT NULL,
        assumptions_json TEXT NOT NULL,
        user_edited INTEGER NOT NULL,
        created_at_utc INTEGER NOT NULL,
        updated_at_utc INTEGER NOT NULL,
        deleted_at_utc INTEGER,
        revision INTEGER NOT NULL
      );
    ''');
      legacy.execute('''
      INSERT INTO meal_entries VALUES
      ('meal-v1', 0, 0, NULL, 'fake', 'v1', 0, 'en', 'medium', '[]', 0, 0, 0, NULL, 0);
    ''');
      legacy.execute('PRAGMA user_version = 1;');
      legacy.close();

      final migrated = AppDatabase.forTesting(NativeDatabase(file));
      final migratedRepository = DriftGoalRepository(migrated);
      expect((await migratedRepository.observe().first).targets, isEmpty);
      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), 2);
      final preserved = await migrated
          .customSelect('SELECT id FROM meal_entries')
          .getSingle();
      expect(preserved.read<String>('id'), 'meal-v1');

      await migrated.close();
      await directory.delete(recursive: true);
    },
  );
}
