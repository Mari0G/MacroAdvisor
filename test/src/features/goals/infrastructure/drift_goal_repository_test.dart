import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/infrastructure/drift_goal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test(
    'replaces the complete active goal set and emits observations',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = DriftGoalRepository(database);
      addTearDown(database.close);

      final observed = repository.observe();
      final first = await observed.first;
      expect(first.hasActiveGoals, isFalse);

      final goals = GoalSet({
        NutrientId.protein: const MinimumGoalTarget(50000),
        NutrientId.energy: const RangeGoalTarget(1800000, 2400000),
      });
      await repository.replace(goals);

      expect(await repository.read(), goals);
      expect((await repository.observe().first).active, hasLength(2));

      await repository.replace(
        GoalSet({NutrientId.fat: const MaximumGoalTarget(70000)}),
      );
      final replaced = await repository.read();
      expect(replaced[NutrientId.protein], const OffGoalTarget());
      expect(replaced[NutrientId.fat], const MaximumGoalTarget(70000));
    },
  );

  test('goal values persist after reopening the schema-v3 database', () async {
    final directory = await Directory.systemTemp.createTemp('macro_goals_');
    final path = '${directory.path}${Platform.pathSeparator}goals.sqlite';
    final firstDatabase = AppDatabase.forTesting(NativeDatabase(File(path)));
    final firstRepository = DriftGoalRepository(firstDatabase);
    await firstRepository.replace(
      GoalSet({NutrientId.salt: const MaximumGoalTarget(6000)}),
    );
    final version = await firstDatabase
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 3);
    await firstDatabase.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(File(path)));
    final reopenedRepository = DriftGoalRepository(reopened);
    expect(
      (await reopenedRepository.read())[NutrientId.salt],
      const MaximumGoalTarget(6000),
    );
    await reopened.close();
    await directory.delete(recursive: true);
  });
}
