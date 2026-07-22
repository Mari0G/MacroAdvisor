import 'package:drift/drift.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class DriftGoalRepository implements GoalRepository {
  DriftGoalRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<GoalSet> observe() =>
      _database.select(_database.goalTargets).watch().map(_mapRows);

  @override
  Future<void> save(GoalSet goals) => _database.transaction(() async {
    await _database.delete(_database.goalTargets).go();
    for (final entry in goals.targets.entries) {
      final target = entry.value;
      await _database
          .into(_database.goalTargets)
          .insert(
            GoalTargetsCompanion.insert(
              nutrientId: entry.key.value,
              targetType: _targetType(target),
              minimumMilliUnits: Value(target.minimumMilliUnits),
              maximumMilliUnits: Value(target.maximumMilliUnits),
            ),
          );
    }
  });

  GoalSet _mapRows(List<GoalTargetRow> rows) => GoalSet({
    for (final row in rows)
      _nutrient(row.nutrientId): switch (row.targetType) {
        'minimum' => MinimumGoalTarget(row.minimumMilliUnits!),
        'maximum' => MaximumGoalTarget(row.maximumMilliUnits!),
        'range' => RangeGoalTarget(
          row.minimumMilliUnits!,
          row.maximumMilliUnits!,
        ),
        _ => throw StateError('Unsupported persisted goal target.'),
      },
  });

  NutrientId _nutrient(String value) => NutrientId.core.firstWhere(
    (nutrient) => nutrient.value == value,
    orElse: () => throw StateError('Unsupported persisted nutrient target.'),
  );

  String _targetType(GoalTarget target) => switch (target) {
    MinimumGoalTarget() => 'minimum',
    MaximumGoalTarget() => 'maximum',
    RangeGoalTarget() => 'range',
  };
}
