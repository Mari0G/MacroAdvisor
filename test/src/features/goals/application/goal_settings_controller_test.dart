import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/application/goal_settings_controller.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  test('saves a complete edited set through the repository', () async {
    final repository = _FakeGoalRepository();
    final container = ProviderContainer(
      overrides: [goalRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(goalSettingsControllerProvider.future);
    final controller = container.read(goalSettingsControllerProvider.notifier);
    controller.setTarget(
      NutrientId.protein,
      const RangeGoalTarget(50000, 90000),
    );

    expect(await controller.save(), isTrue);
    expect(
      repository.saved[NutrientId.protein],
      const RangeGoalTarget(50000, 90000),
    );
    expect(
      container.read(goalSettingsControllerProvider).value!.isDirty,
      isFalse,
    );
  });

  test('keeps the draft and active goals when persistence fails', () async {
    final repository = _FakeGoalRepository()..shouldFail = true;
    final container = ProviderContainer(
      overrides: [goalRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(goalSettingsControllerProvider.future);
    final controller = container.read(goalSettingsControllerProvider.notifier);
    controller.setTarget(NutrientId.energy, const MinimumGoalTarget(1800000));

    await expectLater(controller.save(), throwsA(isA<StateError>()));
    final state = container.read(goalSettingsControllerProvider).value!;
    expect(state.isDirty, isTrue);
    expect(state.failure, isA<StateError>());
    expect(repository.active, GoalSet.empty());
  });
}

class _FakeGoalRepository implements GoalRepository {
  GoalSet active = GoalSet.empty();
  GoalSet saved = GoalSet.empty();
  bool shouldFail = false;

  @override
  Future<GoalSet> read() async => active;

  @override
  Stream<GoalSet> observe() => Stream.value(active);

  @override
  Future<GoalSet> replace(GoalSet goals) async {
    if (shouldFail) throw StateError('goal save failed');
    active = goals;
    saved = goals;
    return goals;
  }
}
