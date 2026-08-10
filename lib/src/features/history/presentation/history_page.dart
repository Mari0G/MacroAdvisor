import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/presentation/goal_text.dart';
import 'package:macro_advisor/src/features/history/application/history_controller.dart';
import 'package:macro_advisor/src/features/history/domain/history.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/nutrition_text.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({this.initialAnchor, super.key});

  final DateTime? initialAnchor;

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    if (widget.initialAnchor != null) {
      final anchor = LocalDay.fromDateTime(widget.initialAnchor!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(historyControllerProvider.notifier).setAnchor(anchor);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(historyControllerProvider);
    final history = ref.watch(historyDisplayProvider(selection));
    return HistoryView(
      selection: selection,
      history: history,
      onNutrientChanged: ref
          .read(historyControllerProvider.notifier)
          .setNutrient,
      onPeriodChanged: ref.read(historyControllerProvider.notifier).setPeriod,
      onAnchorChanged: ref.read(historyControllerProvider.notifier).setAnchor,
      onCustomRangeChanged: ref
          .read(historyControllerProvider.notifier)
          .setCustomRange,
      onRetry: () => ref.invalidate(historyDisplayProvider(selection)),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({
    required this.selection,
    required this.history,
    required this.onNutrientChanged,
    required this.onPeriodChanged,
    required this.onAnchorChanged,
    required this.onCustomRangeChanged,
    required this.onRetry,
    super.key,
  });

  final HistorySelection selection;
  final AsyncValue<HistoryDisplayModel> history;
  final ValueChanged<NutrientId> onNutrientChanged;
  final ValueChanged<HistoryPeriodKind> onPeriodChanged;
  final ValueChanged<LocalDay> onAnchorChanged;
  final void Function(LocalDay start, LocalDay end) onCustomRangeChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              _HistoryControls(
                selection: selection,
                onNutrientChanged: onNutrientChanged,
                onPeriodChanged: onPeriodChanged,
                onAnchorChanged: onAnchorChanged,
                onCustomRangeChanged: onCustomRangeChanged,
              ),
              const SizedBox(height: 16),
              if (!selection.isValid)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.historyInvalidRange),
                  ),
                )
              else
                history.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(l10n.historyFailure),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: onRetry,
                            child: Text(l10n.historyRetry),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (model) => _HistoryData(model: model),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryControls extends StatelessWidget {
  const _HistoryControls({
    required this.selection,
    required this.onNutrientChanged,
    required this.onPeriodChanged,
    required this.onAnchorChanged,
    required this.onCustomRangeChanged,
  });

  final HistorySelection selection;
  final ValueChanged<NutrientId> onNutrientChanged;
  final ValueChanged<HistoryPeriodKind> onPeriodChanged;
  final ValueChanged<LocalDay> onAnchorChanged;
  final void Function(LocalDay start, LocalDay end) onCustomRangeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<NutrientId>(
              key: const Key('history-nutrient-selector'),
              initialValue: selection.nutrient,
              decoration: InputDecoration(labelText: l10n.historyNutrientLabel),
              items: [
                for (final nutrient in NutrientId.core)
                  DropdownMenuItem(
                    value: nutrient,
                    child: Text(nutrientLabel(l10n, nutrient)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onNutrientChanged(value);
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.historyPeriodLabel),
            const SizedBox(height: 8),
            SegmentedButton<HistoryPeriodKind>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: HistoryPeriodKind.rollingWeek,
                  label: Text(l10n.historyPeriodRollingWeek),
                ),
                ButtonSegment(
                  value: HistoryPeriodKind.calendarMonth,
                  label: Text(l10n.historyPeriodCalendarMonth),
                ),
                ButtonSegment(
                  value: HistoryPeriodKind.customRange,
                  label: Text(l10n.historyPeriodCustomRange),
                ),
              ],
              selected: {selection.period},
              onSelectionChanged: (value) => onPeriodChanged(value.first),
            ),
            const SizedBox(height: 12),
            if (selection.period == HistoryPeriodKind.customRange)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _dateButton(
                    context,
                    label: l10n.historyCustomStartLabel,
                    day: selection.customStart ?? selection.anchorDay,
                    locale: locale,
                    onChanged: (day) =>
                        onCustomRangeChanged(day, selection.customEnd ?? day),
                  ),
                  _dateButton(
                    context,
                    label: l10n.historyCustomEndLabel,
                    day: selection.customEnd ?? selection.anchorDay,
                    locale: locale,
                    onChanged: (day) =>
                        onCustomRangeChanged(selection.customStart ?? day, day),
                  ),
                ],
              )
            else
              _dateButton(
                context,
                label: l10n.historyAnchorLabel,
                day: selection.anchorDay,
                locale: locale,
                onChanged: onAnchorChanged,
              ),
          ],
        ),
      ),
    );
  }

  Widget _dateButton(
    BuildContext context, {
    required String label,
    required LocalDay day,
    required String locale,
    required ValueChanged<LocalDay> onChanged,
  }) => OutlinedButton(
    onPressed: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: day.date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) onChanged(LocalDay.fromDateTime(picked));
    },
    child: Text('$label: ${DateFormat.yMd(locale).format(day.date)}'),
  );
}

class _HistoryData extends StatelessWidget {
  const _HistoryData({required this.model});

  final HistoryDisplayModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final highest = model.highestComplete;
    final lowest = model.lowestComplete;
    final nutrient = nutrientLabel(l10n, model.selection.nutrient);
    final start = DateFormat.yMd(locale).format(model.selection.startDay.date);
    final end = DateFormat.yMd(locale).format(model.selection.endDay.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: l10n.historySummary(nutrient, start, end),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.historySummary(nutrient, start, end)),
                  const SizedBox(height: 8),
                  if (!model.hasRecordedMeals) Text(l10n.historyEmpty),
                  Text(l10n.historyIncompleteDays(model.incompleteDays)),
                  if (highest != null)
                    Text(
                      l10n.historyHighest(
                        DateFormat.yMd(locale).format(highest.day.date),
                        nutritionValueText(context, highest.value),
                      ),
                    ),
                  if (lowest != null)
                    Text(
                      l10n.historyLowest(
                        DateFormat.yMd(locale).format(lowest.day.date),
                        nutritionValueText(context, lowest.value),
                      ),
                    ),
                  if (highest == null) Text(l10n.historyNoCompleteExtremes),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          container: true,
          label: l10n.historyChartLabel,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 180,
                child: CustomPaint(painter: _HistoryChartPainter(model.points)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historyDayByDayTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final point in model.points)
                  _HistoryPointRow(model: model, point: point),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryPointRow extends StatelessWidget {
  const _HistoryPointRow({required this.model, required this.point});

  final HistoryDisplayModel model;
  final HistoryPoint point;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMd(locale).format(point.day.date);
    final value = nutritionValueText(context, point.value);
    final state = point.isIncomplete ? l10n.historyIncompleteValue : value;
    final comparison = point.progress == null
        ? l10n.historyNoGoalComparison
        : goalStatusText(l10n, point.progress!.status);
    final semantic = '$date: $state; $comparison';
    return Semantics(
      container: true,
      label: semantic,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(date),
        subtitle: Text(comparison),
        trailing: Text(state),
      ),
    );
  }
}

class _HistoryChartPainter extends CustomPainter {
  _HistoryChartPainter(this.points);

  final List<HistoryPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final known = points
        .where(
          (point) => point.value is KnownNutritionValue && !point.isIncomplete,
        )
        .toList();
    final axis = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      axis,
    );
    if (known.isEmpty) return;
    final maxValue = known.fold<int>(
      0,
      (max, point) =>
          math.max(max, (point.value as KnownNutritionValue).milliUnits),
    );
    final line = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final dots = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final path = Path();
    for (var index = 0; index < known.length; index++) {
      final point = known[index];
      final value = (point.value as KnownNutritionValue).milliUnits;
      final x = known.length == 1
          ? size.width / 2
          : index * size.width / (known.length - 1);
      final y = maxValue == 0
          ? size.height - 8
          : size.height - 8 - (value / maxValue) * (size.height - 16);
      final offset = Offset(x, y);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(offset, 4, dots);
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _HistoryChartPainter oldDelegate) =>
      oldDelegate.points != points;
}
