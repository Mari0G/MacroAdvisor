import 'package:drift/drift.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class DriftGoalRepository implements GoalRepository {
  DriftGoalRepository(this._database);

  final AppDatabase _database;

  @override
  Future<GoalSet> read() async {
    final rows = await _database.select(_database.goalTargets).get();
    return _fromRows(rows);
  }

  @override
  Stream<GoalSet> observe() =>
      _database.select(_database.goalTargets).watch().map(_fromRows);

  @override
  Future<GoalSet> replace(GoalSet goals) async {
    await _database.transaction(() async {
      await _database.delete(_database.goalTargets).go();
      for (final entry in goals.active) {
        final nutrient = entry.key;
        final target = entry.value;
        await _database
            .into(_database.goalTargets)
            .insert(
              GoalTargetsCompanion.insert(
                nutrientId: nutrient.value,
                unit: nutrient.canonicalUnit.name,
                targetKind: target.kind.name,
                minimumMilliUnits: Value(target.minimumMilliUnits),
                maximumMilliUnits: Value(target.maximumMilliUnits),
              ),
            );
      }
    });
    return goals;
  }

  GoalSet _fromRows(List<GoalTargetRow> rows) {
    return GoalSet({
      for (final row in rows)
        _nutrient(row.nutrientId, row.unit): GoalTarget.fromValues(
          GoalTargetKind.values.byName(row.targetKind),
          minimumMilliUnits: row.minimumMilliUnits,
          maximumMilliUnits: row.maximumMilliUnits,
        ),
    });
  }

  NutrientId _nutrient(String value, String unit) {
    for (final nutrient in NutrientId.core) {
      if (nutrient.value == value) return nutrient;
    }
    return NutrientId(value, NutritionUnit.values.byName(unit));
  }
}
