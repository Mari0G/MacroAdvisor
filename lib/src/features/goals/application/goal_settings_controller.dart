import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';

enum GoalSettingsPhase { loading, ready, saving, failure }

class GoalSettingsState {
  const GoalSettingsState({required this.phase, this.goals});

  final GoalSettingsPhase phase;
  final GoalSet? goals;

  bool get isBusy =>
      phase == GoalSettingsPhase.loading || phase == GoalSettingsPhase.saving;
}

class GoalSettingsController extends Notifier<GoalSettingsState> {
  @override
  GoalSettingsState build() {
    unawaited(_load());
    return const GoalSettingsState(phase: GoalSettingsPhase.loading);
  }

  Future<void> save(GoalSet goals) async {
    if (state.isBusy) return;
    state = GoalSettingsState(phase: GoalSettingsPhase.saving, goals: goals);
    try {
      await ref.read(goalRepositoryProvider).save(goals);
      state = GoalSettingsState(phase: GoalSettingsPhase.ready, goals: goals);
    } catch (_) {
      state = GoalSettingsState(phase: GoalSettingsPhase.failure, goals: goals);
    }
  }

  Future<void> retry() => _load();

  Future<void> _load() async {
    try {
      final goals = await ref.read(goalRepositoryProvider).observe().first;
      state = GoalSettingsState(phase: GoalSettingsPhase.ready, goals: goals);
    } catch (_) {
      state = const GoalSettingsState(phase: GoalSettingsPhase.failure);
    }
  }
}

final goalSettingsControllerProvider =
    NotifierProvider<GoalSettingsController, GoalSettingsState>(
      GoalSettingsController.new,
    );
