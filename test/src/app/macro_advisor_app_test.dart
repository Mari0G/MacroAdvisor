import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/presentation/type_c_components.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/settings/application/appearance_controller.dart';
import 'package:macro_advisor/src/features/settings/domain/appearance_settings.dart';

void main() {
  final clock = _FixedClock(DateTime(2025, 1, 2, 9));

  Widget buildApp(Locale locale) => ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(clock),
      mealRepositoryProvider.overrideWithValue(_EmptyMealRepository()),
      goalRepositoryProvider.overrideWithValue(_EmptyGoalRepository()),
      mealPhotoSourceProvider.overrideWithValue(_NoopPhotoSource()),
    ],
    child: MacroAdvisorApp(locale: locale),
  );

  testWidgets('shows the localized English empty Today shell', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Today').first, findsOneWidget);
    expect(find.text('No meals or drinks recorded'), findsOneWidget);
    expect(find.text('Meals and drinks (0)'), findsOneWidget);
    expect(find.text('Record meal'), findsOneWidget);
    expect(find.byTooltip('Record meal'), findsOneWidget);
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
    expect(find.text('Mahlzeit erfassen'), findsOneWidget);
    expect(find.byTooltip('Mahlzeit erfassen'), findsOneWidget);
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

  testWidgets(
    'both Today record actions open source selection before description',
    (tester) async {
      await tester.pumpWidget(buildApp(const Locale('en')));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('describe-meal-source')), findsOneWidget);
      await tester.tap(find.byKey(const Key('describe-meal-source')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-description-field')), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Record meal'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Record meal'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('describe-meal-source')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('meal-description-field')), findsOneWidget);
    },
  );

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
    expect(find.text('Mahlzeit erfassen'), findsOneWidget);
  });

  for (final locale in ['en', 'de']) {
    testWidgets('$locale palette switches root theme on Settings without pop', (
      tester,
    ) async {
      if (locale == 'de') {
        tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(
          tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
        );
      }
      final settings = _AppearanceStore();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWithValue(clock),
            mealRepositoryProvider.overrideWithValue(_EmptyMealRepository()),
            goalRepositoryProvider.overrideWithValue(_EmptyGoalRepository()),
            mealPhotoSourceProvider.overrideWithValue(_NoopPhotoSource()),
            appearanceSettingsProvider.overrideWithValue(settings),
          ],
          child: MacroAdvisorApp(locale: Locale(locale)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('today-settings-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('palette-lime')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('palette-ocean')));
      await tester.tap(find.byKey(const Key('palette-ocean')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('palette-ocean')), findsOneWidget);
      expect(settings.id, 'ocean');
      expect(
        tester
            .widget<MaterialApp>(find.byType(MaterialApp))
            .theme!
            .colorScheme
            .primary,
        const Color(0xff58d7ff),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('palette change keeps Settings scroll position', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = _AppearanceStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(clock),
          mealRepositoryProvider.overrideWithValue(_EmptyMealRepository()),
          goalRepositoryProvider.overrideWithValue(_EmptyGoalRepository()),
          mealPhotoSourceProvider.overrideWithValue(_NoopPhotoSource()),
          appearanceSettingsProvider.overrideWithValue(settings),
        ],
        child: const MacroAdvisorApp(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('today-settings-button')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -80));
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    final before = scroll.position.pixels;
    expect(before, greaterThan(0));
    await tester.tap(find.byKey(const Key('palette-ocean')));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, closeTo(before, 1));
    expect(settings.id, 'ocean');
  });

  testWidgets('failed palette save reverts and offers retry at 200% text', (
    tester,
  ) async {
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    final settings = _AppearanceStore()..failSave = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(clock),
          mealRepositoryProvider.overrideWithValue(_EmptyMealRepository()),
          goalRepositoryProvider.overrideWithValue(_EmptyGoalRepository()),
          mealPhotoSourceProvider.overrideWithValue(_NoopPhotoSource()),
          appearanceSettingsProvider.overrideWithValue(settings),
        ],
        child: const MacroAdvisorApp(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('today-settings-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('palette-ocean')));
    await tester.tap(find.byKey(const Key('palette-ocean')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TypeCSelectionRow>(find.byKey(const Key('palette-lime')))
          .selected,
      isTrue,
    );
    expect(
      find.text(
        'The palette could not be saved. The previous color is active.',
      ),
      findsOneWidget,
    );
    settings.failSave = false;
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry').first);
    await tester.pumpAndSettle();
    expect(settings.id, 'ocean');
    expect(
      find.text(
        'The palette could not be saved. The previous color is active.',
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

class _AppearanceStore implements AppearanceSettings {
  String id = 'lime';
  bool failSave = false;
  @override
  Future<String?> readPaletteId() async => id;
  @override
  Stream<String?> observePaletteId() => Stream.value(id);
  @override
  Future<void> savePaletteId(String value) async {
    if (failSave) throw StateError('save');
    id = value;
  }
}

class _NoopPhotoSource implements MealPhotoSource {
  @override
  Future<MealPhotoAcquisition> acquire(MealPhotoSourceType source) async =>
      const CancelledMealPhotoAcquisition();

  @override
  Future<MealPhotoAcquisition?> recoverLostData() async => null;
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
  Stream<List<MealEntry>> observeRange(DateTime start, DateTime end) =>
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
  Future<GoalSet> read() async => GoalSet.empty();

  @override
  Stream<GoalSet> observe() => Stream.value(GoalSet.empty());

  @override
  Future<GoalSet> replace(GoalSet goals) async => goals;
}

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
