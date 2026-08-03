import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  throw UnimplementedError('GoalRepository must be provided by the app.');
});

final activeGoalSetProvider = StreamProvider<GoalSet>((ref) {
  return ref.watch(goalRepositoryProvider).observe();
});
