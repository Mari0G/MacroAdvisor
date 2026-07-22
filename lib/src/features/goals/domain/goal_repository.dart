import 'package:macro_advisor/src/features/goals/domain/goal.dart';

abstract interface class GoalRepository {
  Stream<GoalSet> observe();

  /// Replaces every target in one atomic update.
  Future<void> save(GoalSet goals);
}
