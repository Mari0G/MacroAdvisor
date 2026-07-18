import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TodayView(
    date: ref.watch(clockProvider).now(),
    onOpenSettings: () => Navigator.of(context).pushNamed(AppRoutes.settings),
    onRecordMeal: () {},
  );
}

class TodayView extends StatelessWidget {
  const TodayView({
    required this.date,
    required this.onOpenSettings,
    required this.onRecordMeal,
    super.key,
  });

  final DateTime date;
  final VoidCallback onOpenSettings;
  final VoidCallback onRecordMeal;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat.yMMMMEEEEd(locale).format(date);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.todayTitle),
            Text(dateLabel, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: localizations.settingsTooltip,
            onPressed: onOpenSettings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onRecordMeal,
        icon: const Icon(Icons.add),
        label: Text(localizations.recordMealAction),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final expanded = MediaQuery.sizeOf(context).width >= 840;
              final content = _TodayContent(onRecordMeal: onRecordMeal);
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: expanded
                    ? Row(
                        key: const Key('today-expanded-layout'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: _DailyOverview()),
                          const SizedBox(width: 24),
                          Expanded(child: content),
                        ],
                      )
                    : Column(
                        key: const Key('today-compact-layout'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _DailyOverview(),
                          const SizedBox(height: 24),
                          content,
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DailyOverview extends StatelessWidget {
  const _DailyOverview();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.dailyNutritionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(localizations.dailyNutritionEmpty),
          ],
        ),
      ),
    );
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.onRecordMeal});

  final VoidCallback onRecordMeal;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.mealsAndDrinksTitle(0),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.restaurant_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  localizations.todayEmptyTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(localizations.todayEmptyBody, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRecordMeal,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.recordMealAction),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
