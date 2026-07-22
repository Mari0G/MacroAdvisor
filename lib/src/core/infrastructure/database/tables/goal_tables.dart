import 'package:drift/drift.dart';

@DataClassName('GoalTargetRow')
class GoalTargets extends Table {
  TextColumn get nutrientId => text()();
  TextColumn get targetType => text()();
  IntColumn get minimumMilliUnits => integer().nullable()();
  IntColumn get maximumMilliUnits => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {nutrientId};
}
