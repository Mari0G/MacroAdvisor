import 'package:macro_advisor/src/features/goals/domain/goal.dart';

abstract interface class GoalRepository {
  Future<GoalSet> read();

  Stream<GoalSet> observe();

  /// Replaces the complete active set in one transaction.
  Future<GoalSet> replace(GoalSet goals);
}
