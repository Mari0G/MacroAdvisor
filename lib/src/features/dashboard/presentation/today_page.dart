import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/app/app_theme.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/core/presentation/type_c_components.dart';
import 'package:macro_advisor/src/features/dashboard/application/dashboard_controller.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/application/today_progress.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/presentation/goal_text.dart';
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
      goals: ref.watch(activeGoalSetProvider),
      onSelectDay: ref.read(dashboardControllerProvider.notifier).selectDay,
      onOpenSettings: () => Navigator.of(context).pushNamed(AppRoutes.settings),
      onOpenHistory: () => Navigator.of(
        context,
      ).pushNamed(AppRoutes.history, arguments: selectedDay.date),
      onRecordMeal: () =>
          Navigator.of(context).pushNamed(AppRoutes.chooseMealSource),
      onOpenMealDetail: (id) =>
          Navigator.of(context).pushNamed(AppRoutes.mealDetail, arguments: id),
      onRetry: () => ref.invalidate(dashboardDisplayProvider(selectedDay)),
    );
  }
}

class TodayView extends StatelessWidget {
  const TodayView({
    required this.day,
    required this.currentDay,
    required this.dashboard,
    this.goals,
    required this.onSelectDay,
    required this.onOpenSettings,
    this.onOpenHistory,
    required this.onRecordMeal,
    required this.onOpenMealDetail,
    required this.onRetry,
    super.key,
  });

  final LocalDay day;
  final LocalDay currentDay;
  final AsyncValue<DashboardDisplayModel> dashboard;
  final AsyncValue<GoalSet>? goals;
  final ValueChanged<LocalDay> onSelectDay;
  final VoidCallback onOpenSettings;
  final VoidCallback? onOpenHistory;
  final VoidCallback onRecordMeal;
  final ValueChanged<String> onOpenMealDetail;
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
        toolbarHeight: 82,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              dateLabel,
              style: TextStyle(color: TypeCTokens.of(context).muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('history-button'),
            icon: const Icon(Icons.history),
            tooltip: l10n.historyTooltip,
            onPressed: onOpenHistory,
          ),
          IconButton(
            key: const Key('today-settings-button'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTooltip,
            onPressed: onOpenSettings,
          ),
        ],
      ),
      floatingActionButton: showRecordAction
          ? FloatingActionButton(
              key: const Key('today-record-meal-button'),
              onPressed: onRecordMeal,
              tooltip: l10n.recordMealAction,
              child: const Icon(Icons.add),
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
                        goals: goals ?? AsyncData(GoalSet.empty()),
                        onRecordMeal: onRecordMeal,
                        onOpenMealDetail: onOpenMealDetail,
                        onRetry: onRetry,
                      );
                      return expanded
                          ? KeyedSubtree(
                              key: const Key('today-expanded-layout'),
                              child: content,
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
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.dashboard,
    required this.goals,
    required this.onRecordMeal,
    required this.onOpenMealDetail,
    required this.onRetry,
  });

  final AsyncValue<DashboardDisplayModel> dashboard;
  final AsyncValue<GoalSet> goals;
  final VoidCallback onRecordMeal;
  final ValueChanged<String> onOpenMealDetail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => dashboard.when(
    loading: () => const _DashboardLoading(),
    error: (error, _) => _DashboardFailure(onRetry: onRetry),
    data: (model) => _DashboardData(
      model: model,
      goals: goals is AsyncData<GoalSet>
          ? goals.value ?? GoalSet.empty()
          : GoalSet.empty(),
      onRecordMeal: onRecordMeal,
      onOpenMealDetail: onOpenMealDetail,
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
  });

  final DashboardDisplayModel model;
  final GoalSet goals;
  final VoidCallback onRecordMeal;
  final ValueChanged<String> onOpenMealDetail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overviewNutrients = <NutrientId>[
      NutrientId.energy,
      NutrientId.protein,
      NutrientId.carbohydrates,
      NutrientId.fat,
    ];
    final progress = TodayProgressModel.fromDashboard(model, goals);
    final energyGoal = [
      for (final item in progress.nutrients)
        if (item.nutrient == NutrientId.energy) item,
    ].firstOrNull;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (model.hasIncompleteData) ...[
          _IncompleteBanner(),
          const SizedBox(height: 12),
        ],
        TypeCSectionHeader(title: l10n.dailyNutritionTitle),
        TypeCHeroCard(
          child: _EnergyHero(total: model[NutrientId.energy], goal: energyGoal),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final nutrient in overviewNutrients.skip(1))
                  _NutrientTile(total: model[nutrient], width: tileWidth),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        _GoalProgressSection(progress: progress),
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
      ],
    );
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TypeCSectionHeader(
          title: l10n.mealsAndDrinksTitle(model.entries.length),
        ),
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
    final expanded = MediaQuery.sizeOf(context).width >= 840;
    return expanded
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: left),
              const SizedBox(width: 24),
              Expanded(flex: 6, child: right),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 16), right],
          );
  }
}

class _EnergyHero extends StatelessWidget {
  const _EnergyHero({required this.total, required this.goal});
  final DashboardNutrientTotal total;
  final TodayNutrientProgress? goal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ratio = goal?.progress.ratio;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nutrientEnergy,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                nutritionValueText(context, total.value),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (total.isIncomplete) Text(l10n.incompleteDataTitle),
              if (goal != null) ...[
                const SizedBox(height: 6),
                Text(goalTargetText(context, NutrientId.energy, goal!.target)),
                Text(goalStatusText(l10n, goal!.progress.status)),
              ],
            ],
          ),
        ),
        if (goal != null) ...[
          const SizedBox(width: 12),
          Semantics(
            label: l10n.goalProgressSemantics(
              l10n.nutrientEnergy,
              nutritionValueText(context, total.value),
              goalTargetText(context, NutrientId.energy, goal!.target),
              goalStatusText(l10n, goal!.progress.status),
            ),
            child: SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: CircularProgressIndicator(
                      value: (ratio ?? 0).clamp(0, 1).toDouble(),
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    ratio == null
                        ? l10n.unknownValue
                        : '${(ratio * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GoalProgressSection extends StatelessWidget {
  const _GoalProgressSection({required this.progress});

  final TodayProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!progress.hasGoals) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(l10n.noGoalsTitle),
          subtitle: Text(l10n.noGoalsBody),
        ),
      );
    }
    final otherNutrients = progress.nutrients.where(
      (item) => item.nutrient != NutrientId.energy,
    );
    if (otherNutrients.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.goalProgressTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final nutrient in otherNutrients)
          _GoalProgressCard(progress: nutrient),
      ],
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.progress});

  final TodayNutrientProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nutrient = nutrientLabel(l10n, progress.nutrient);
    final current = nutritionValueText(context, progress.total.value);
    final target = goalTargetText(context, progress.nutrient, progress.target);
    final status = goalStatusText(l10n, progress.progress.status);
    return Semantics(
      container: true,
      label: l10n.goalProgressSemantics(nutrient, current, target, status),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(nutrient)),
                  if (!progress.progress.isIncomplete) Text(status),
                ],
              ),
              const SizedBox(height: 4),
              Text('$current · $target'),
              if (progress.progress.ratio case final ratio?) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(value: ratio),
              ],
              if (progress.progress.isIncomplete)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(status),
                ),
            ],
          ),
        ),
      ),
    );
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
  const _NutrientTile({required this.total, this.width = 140});

  final DashboardNutrientTotal total;
  final double width;

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
        width: width,
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
              key: const Key('empty-record-meal-button'),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        isThreeLine: hasUnknown,
        leading: CircleAvatar(
          backgroundColor: TypeCTokens.of(context).meal,
          child: const Icon(Icons.restaurant),
        ),
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
