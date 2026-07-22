import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/dashboard/application/dashboard_controller.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(dashboardControllerProvider);
    final currentDay = LocalDay.fromDateTime(ref.watch(clockProvider).now());
    return TodayView(
      day: selectedDay,
      currentDay: currentDay,
      dashboard: ref.watch(dashboardDisplayProvider(selectedDay)),
      goals: ref.watch(goalSetProvider),
      onSelectDay: ref.read(dashboardControllerProvider.notifier).selectDay,
      onOpenSettings: () => Navigator.of(context).pushNamed(AppRoutes.settings),
      onRecordMeal: () =>
          Navigator.of(context).pushNamed(AppRoutes.describeMeal),
      onOpenMealDetail: (id) =>
          Navigator.of(context).pushNamed(AppRoutes.mealDetail, arguments: id),
      onOpenGoals: () =>
          Navigator.of(context).pushNamed(AppRoutes.goalSettings),
      onRetry: () {
        ref.invalidate(dashboardDisplayProvider(selectedDay));
        ref.invalidate(goalSetProvider);
      },
    );
  }
}

class TodayView extends StatelessWidget {
  const TodayView({
    required this.day,
    required this.currentDay,
    required this.dashboard,
    required this.goals,
    required this.onSelectDay,
    required this.onOpenSettings,
    required this.onRecordMeal,
    required this.onOpenMealDetail,
    required this.onOpenGoals,
    required this.onRetry,
    super.key,
  });

  final LocalDay day;
  final LocalDay currentDay;
  final AsyncValue<DashboardDisplayModel> dashboard;
  final AsyncValue<GoalSet> goals;
  final ValueChanged<LocalDay> onSelectDay;
  final VoidCallback onOpenSettings;
  final VoidCallback onRecordMeal;
  final ValueChanged<String> onOpenMealDetail;
  final VoidCallback onOpenGoals;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final selectedDate = day.date;
    final dateLabel = DateFormat.yMMMMEEEEd(locale).format(selectedDate);
    final showRecordAction = day == currentDay;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.todayTitle),
            Text(dateLabel, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTooltip,
            onPressed: onOpenSettings,
          ),
        ],
      ),
      floatingActionButton: showRecordAction
          ? FloatingActionButton.extended(
              onPressed: onRecordMeal,
              icon: const Icon(Icons.add),
              label: Text(l10n.recordMealAction),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => onRetry(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DaySelector(
                    day: day,
                    currentDay: currentDay,
                    onSelectDay: onSelectDay,
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final expanded = MediaQuery.sizeOf(context).width >= 840;
                      final content = _DashboardBody(
                        dashboard: dashboard,
                        goals: goals,
                        onRecordMeal: onRecordMeal,
                        onOpenMealDetail: onOpenMealDetail,
                        onOpenGoals: onOpenGoals,
                        onRetry: onRetry,
                      );
                      return expanded
                          ? Row(
                              key: const Key('today-expanded-layout'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Expanded(child: content)],
                            )
                          : Column(
                              key: const Key('today-compact-layout'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [content],
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.day,
    required this.currentDay,
    required this.onSelectDay,
  });

  final LocalDay day;
  final LocalDay currentDay;
  final ValueChanged<LocalDay> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat.yMMMMEEEEd(locale).format(day.date);
    final shortLabel = DateFormat.MMMd(locale).format(day.date);
    return Semantics(
      container: true,
      label: l10n.daySelectorLabel,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.previousDayTooltip,
                onPressed: () => onSelectDay(day.previous()),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: day.date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      onSelectDay(LocalDay.fromDateTime(picked));
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        day == currentDay ? l10n.todayTitle : shortLabel,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        dateLabel,
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.nextDayTooltip,
                onPressed: () => onSelectDay(day.next()),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.dashboard,
    required this.goals,
    required this.onRecordMeal,
    required this.onOpenMealDetail,
    required this.onOpenGoals,
    required this.onRetry,
  });

  final AsyncValue<DashboardDisplayModel> dashboard;
  final AsyncValue<GoalSet> goals;
  final VoidCallback onRecordMeal;
  final ValueChanged<String> onOpenMealDetail;
  final VoidCallback onOpenGoals;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => dashboard.when(
    loading: () => const _DashboardLoading(),
    error: (error, _) => _DashboardFailure(onRetry: onRetry),
    data: (model) => goals.when(
      loading: () => const _DashboardLoading(),
      error: (error, _) => _DashboardFailure(onRetry: onRetry),
      data: (goalSet) => _DashboardData(
        model: model,
        goals: goalSet,
        onRecordMeal: onRecordMeal,
        onOpenMealDetail: onOpenMealDetail,
        onOpenGoals: onOpenGoals,
      ),
    ),
  );
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.dashboardLoading),
          ],
        ),
      ),
    );
  }
}

class _DashboardFailure extends StatelessWidget {
  const _DashboardFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(l10n.dashboardFailure, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(l10n.retryAction)),
          ],
        ),
      ),
    );
  }
}

class _DashboardData extends StatelessWidget {
  const _DashboardData({
    required this.model,
    required this.goals,
    required this.onRecordMeal,
    required this.onOpenMealDetail,
    required this.onOpenGoals,
  });

  final DashboardDisplayModel model;
  final GoalSet goals;
  final VoidCallback onRecordMeal;
  final ValueChanged<String> onOpenMealDetail;
  final VoidCallback onOpenGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overviewNutrients = <NutrientId>[
      NutrientId.energy,
      NutrientId.protein,
      NutrientId.carbohydrates,
      NutrientId.fat,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (model.hasIncompleteData) ...[
          _IncompleteBanner(),
          const SizedBox(height: 12),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyNutritionTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final nutrient in overviewNutrients)
                      _NutrientTile(total: model[nutrient]),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _GoalProgressSection(
          model: model,
          goals: goals,
          onOpenGoals: onOpenGoals,
        ),
        const SizedBox(height: 12),
        Card(
          child: ExpansionTile(
            title: Text(l10n.allNutrientsTitle),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              for (final nutrient in NutrientId.core)
                _NutrientRow(total: model[nutrient]),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.mealsAndDrinksTitle(model.entries.length),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (model.isEmpty)
          _EmptyDay(onRecordMeal: onRecordMeal)
        else
          for (final entry in model.entries)
            _MealEntryCard(
              entry: entry,
              onTap: () => onOpenMealDetail(entry.id),
            ),
      ],
    );
  }
}

class _GoalProgressSection extends StatelessWidget {
  const _GoalProgressSection({
    required this.model,
    required this.goals,
    required this.onOpenGoals,
  });

  final DashboardDisplayModel model;
  final GoalSet goals;
  final VoidCallback onOpenGoals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (goals.targets.isEmpty) {
      return Card(
        key: const Key('dashboard-no-goals'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.goalProgressTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(l10n.noGoalsBody),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onOpenGoals,
                child: Text(l10n.setDailyTargetsAction),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.goalProgressTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final nutrient in NutrientId.core)
              if (goals[nutrient] case final target?)
                _GoalProgressCard(
                  progress: model.progressFor(nutrient, goals),
                  target: target,
                ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.progress, required this.target});

  final GoalProgress progress;
  final GoalTarget target;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = nutrientLabel(l10n, progress.nutrient);
    final value = nutritionValueText(context, progress.value);
    final targetText = _targetText(context, target);
    final status = switch (progress.status) {
      GoalProgressStatus.unknown => l10n.goalProgressUnknown,
      GoalProgressStatus.belowTarget => l10n.goalProgressBelow,
      GoalProgressStatus.withinTarget => l10n.goalProgressWithin,
      GoalProgressStatus.aboveTarget => l10n.goalProgressAbove,
      GoalProgressStatus.noGoal => l10n.noGoalsBody,
    };
    return Semantics(
      container: true,
      label: l10n.goalProgressSemantics(label, value, targetText, status),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ListTile(
          title: Text(label),
          subtitle: Text('$targetText · $status'),
          trailing: Text(value),
        ),
      ),
    );
  }

  String _targetText(BuildContext context, GoalTarget target) {
    final l10n = AppLocalizations.of(context);
    final unit = unitLabel(progress.nutrient.canonicalUnit);
    String amount(int value) =>
        '${NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag()).format(value / 1000)} $unit';
    return switch (target) {
      MinimumGoalTarget(:final minimumMilliUnits) => l10n.goalMinimum(
        amount(minimumMilliUnits),
      ),
      MaximumGoalTarget(:final maximumMilliUnits) => l10n.goalMaximum(
        amount(maximumMilliUnits),
      ),
      RangeGoalTarget(:final minimumMilliUnits, :final maximumMilliUnits) =>
        l10n.goalRange(amount(minimumMilliUnits), amount(maximumMilliUnits)),
    };
  }
}

class _IncompleteBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.incompleteDataTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.incompleteDataBody),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientTile extends StatelessWidget {
  const _NutrientTile({required this.total});

  final DashboardNutrientTotal total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = nutrientLabel(l10n, total.nutrient);
    final value = nutritionValueText(context, total.value);
    final incomplete = total.isIncomplete
        ? ' · ${l10n.incompleteDataTitle}'
        : '';
    return Semantics(
      container: true,
      label: '$label: $value$incomplete',
      child: SizedBox(
        width: 140,
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                if (total.isIncomplete)
                  Text(
                    l10n.incompleteDataTitle,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.total});

  final DashboardNutrientTotal total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = nutrientLabel(l10n, total.nutrient);
    return Semantics(
      label: '$label: ${nutritionValueText(context, total.value)}',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        trailing: Text(nutritionValueText(context, total.value)),
        subtitle: total.isIncomplete ? Text(l10n.incompleteDataTitle) : null,
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.onRecordMeal});

  final VoidCallback onRecordMeal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.restaurant_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.todayEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.todayEmptyBody, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRecordMeal,
              icon: const Icon(Icons.add),
              label: Text(l10n.recordMealAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealEntryCard extends StatelessWidget {
  const _MealEntryCard({required this.entry, required this.onTap});

  final MealEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final localOccurrence = entry.occurredAtUtc.add(
      Duration(minutes: entry.occurredOffsetMinutes),
    );
    final title = entry.description?.trim().isNotEmpty == true
        ? entry.description!.trim()
        : entry.items.map((item) => item.name).join(', ');
    final hasUnknown = entry.items.any(
      (item) => item.nutrition.values.values.any((value) => !value.isKnown),
    );
    final energy = nutritionValueText(context, entry.totals[NutrientId.energy]);
    return Card(
      child: ListTile(
        isThreeLine: hasUnknown,
        leading: const Icon(Icons.restaurant),
        title: Text(title),
        subtitle: Text(
          '${DateFormat.Hm(locale).format(localOccurrence)} · $energy'
          '${hasUnknown ? ' · ${l10n.incompleteDataTitle}' : ''}',
        ),
        onTap: onTap,
      ),
    );
  }
}
