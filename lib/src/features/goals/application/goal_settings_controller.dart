import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class GoalEditorState {
  const GoalEditorState({
    required this.goals,
    required this.savedGoals,
    this.isSaving = false,
    this.failure,
  });

  final GoalSet goals;
  final GoalSet savedGoals;
  final bool isSaving;
  final Object? failure;

  bool get isDirty => goals != savedGoals;

  GoalEditorState copyWith({
    GoalSet? goals,
    GoalSet? savedGoals,
    bool? isSaving,
    Object? failure,
  }) => GoalEditorState(
    goals: goals ?? this.goals,
    savedGoals: savedGoals ?? this.savedGoals,
    isSaving: isSaving ?? this.isSaving,
    failure: failure,
  );
}

class GoalSettingsController extends AsyncNotifier<GoalEditorState> {
  @override
  Future<GoalEditorState> build() async {
    final goals = await ref.watch(goalRepositoryProvider).read();
    return GoalEditorState(goals: goals, savedGoals: goals);
  }

  void setTarget(NutrientId nutrient, GoalTarget target) {
    final current = state is AsyncData<GoalEditorState> ? state.value : null;
    if (current == null || current.isSaving) return;
    state = AsyncData(
      current.copyWith(
        goals: GoalSet({...current.goals.values, nutrient: target}),
        failure: null,
      ),
    );
  }

  Future<bool> save() async {
    final current = state is AsyncData<GoalEditorState> ? state.value : null;
    if (current == null || current.isSaving) return false;
    state = AsyncData(current.copyWith(isSaving: true, failure: null));
    try {
      final saved = await ref
          .read(goalRepositoryProvider)
          .replace(current.goals);
      state = AsyncData(GoalEditorState(goals: saved, savedGoals: saved));
      return true;
    } catch (error, stackTrace) {
      state = AsyncData(current.copyWith(isSaving: false, failure: error));
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void discardChanges() {
    final current = state is AsyncData<GoalEditorState> ? state.value : null;
    if (current == null || current.isSaving) return;
    state = AsyncData(
      current.copyWith(goals: current.savedGoals, failure: null),
    );
  }
}

final goalSettingsControllerProvider =
    AsyncNotifierProvider.autoDispose<GoalSettingsController, GoalEditorState>(
      GoalSettingsController.new,
    );

String? validateGoalTarget(
  GoalTargetKind kind, {
  int? minimumMilliUnits,
  int? maximumMilliUnits,
}) => GoalTarget.validate(
  kind,
  minimumMilliUnits: minimumMilliUnits,
  maximumMilliUnits: maximumMilliUnits,
);
