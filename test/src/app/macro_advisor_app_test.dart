import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';

void main() {
  final clock = _FixedClock(DateTime(2025, 1, 2, 9));

  Widget buildApp(Locale locale) => ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(clock),
      mealRepositoryProvider.overrideWithValue(_EmptyMealRepository()),
      goalRepositoryProvider.overrideWithValue(_EmptyGoalRepository()),
    ],
    child: MacroAdvisorApp(locale: locale),
  );

  testWidgets('shows the localized English empty Today shell', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Today').first, findsOneWidget);
    expect(find.text('No meals or drinks recorded'), findsOneWidget);
    expect(find.text('Meals and drinks (0)'), findsOneWidget);
    expect(find.text('Record meal'), findsNWidgets(2));
    expect(find.byTooltip('Open settings'), findsOneWidget);
  });

  testWidgets('shows the localized German empty Today shell', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('de')));
    await tester.pumpAndSettle();

    expect(find.text('Heute').first, findsOneWidget);
    expect(
      find.text('Noch keine Mahlzeiten oder Getränke erfasst'),
      findsOneWidget,
    );
    expect(find.text('Mahlzeiten und Getränke (0)'), findsOneWidget);
    expect(find.text('Mahlzeit erfassen'), findsNWidgets(2));
    expect(find.byTooltip('Einstellungen öffnen'), findsOneWidget);
  });

  testWidgets('opens the Settings placeholder from Today', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('en')));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(
      find.text('Goals and language settings will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('both Today record actions open the meal description page', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const Locale('en')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-description-field')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Record meal'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Record meal'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('meal-description-field')), findsOneWidget);
  });

  testWidgets('uses a compact layout below the expanded breakpoint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today-compact-layout')), findsOneWidget);
    expect(find.byKey(const Key('today-expanded-layout')), findsNothing);
  });

  testWidgets('uses an expanded layout at wide widths', (tester) async {
    tester.view.physicalSize = const Size(1000, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today-expanded-layout')), findsOneWidget);
    expect(find.byKey(const Key('today-compact-layout')), findsNothing);
  });

  testWidgets('remains usable with German text at 200 percent scale', (
    tester,
  ) async {
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );

    await tester.pumpWidget(buildApp(const Locale('de')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Mahlzeit erfassen'), findsNWidgets(2));
  });
}

class _EmptyMealRepository implements MealRepository {
  @override
  Future<MealEntry> create(MealEntryDraft draft) => throw UnimplementedError();

  @override
  Future<MealEntry?> findById(String id, {bool includeDeleted = false}) =>
      throw UnimplementedError();

  @override
  Stream<List<MealEntry>> observeDay(DateTime localDay) =>
      Stream.value(const <MealEntry>[]);

  @override
  Future<MealEntry> update(MealEntry entry) => throw UnimplementedError();

  @override
  Future<MealEntry> softDelete({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();

  @override
  Future<MealEntry> restore({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();
}

class _EmptyGoalRepository implements GoalRepository {
  @override
  Stream<GoalSet> observe() => Stream.value(GoalSet.empty());

  @override
  Future<void> save(GoalSet goals) => throw UnimplementedError();
}

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
