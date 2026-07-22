import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/application/goal_settings_controller.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test(
    'loads and saves a complete goal set through the repository port',
    () async {
      final repository = _FakeGoalRepository();
      final container = ProviderContainer(
        overrides: [goalRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(
        container.read(goalSettingsControllerProvider).phase,
        GoalSettingsPhase.loading,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(goalSettingsControllerProvider).phase,
        GoalSettingsPhase.ready,
      );

      final goals = GoalSet({
        NutrientId.protein: const MinimumGoalTarget(30000),
      });
      await container.read(goalSettingsControllerProvider.notifier).save(goals);

      expect(repository.saved, goals);
      expect(
        container.read(goalSettingsControllerProvider).phase,
        GoalSettingsPhase.ready,
      );
    },
  );
}

class _FakeGoalRepository implements GoalRepository {
  GoalSet saved = GoalSet.empty();

  @override
  Stream<GoalSet> observe() => Stream.value(saved);

  @override
  Future<void> save(GoalSet goals) async {
    saved = goals;
  }
}
