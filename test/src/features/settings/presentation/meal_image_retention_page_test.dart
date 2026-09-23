import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/meals/application/meal_image_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_image.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/presentation/meal_detail_page.dart';
import 'package:macro_advisor/src/features/settings/application/meal_image_retention_provider.dart';
import 'package:macro_advisor/src/features/settings/domain/meal_image_retention_settings.dart';
import 'package:macro_advisor/src/features/settings/presentation/settings_page.dart';

void main() {
  for (final language in ['en', 'de']) {
    testWidgets(
      '$language settings supports cancel, failure and retry at 200%',
      (tester) async {
        final settings = _FakeRetentionSettings()..failSave = true;
        await tester.pumpWidget(
          _settingsApp(Locale(language), settings, scale: 2),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(SettingsPage)),
        );
        expect(find.text(l10n.savedMealImagesEnabledBody), findsOneWidget);
        final toggle = find.byKey(const Key('retention-setting-switch'));
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(find.text(l10n.disableSavedMealImagesTitle), findsOneWidget);
        await tester.tap(find.text(l10n.cancelAction));
        await tester.pumpAndSettle();
        expect(settings.requests, isEmpty);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.disableSavedMealImagesAction));
        await tester.pumpAndSettle();
        expect(settings.enabled, isTrue);
        expect(find.text(l10n.savedMealImagesSaveFailed), findsOneWidget);
        expect(
          tester
              .widgetList<Semantics>(find.byType(Semantics))
              .any((widget) => widget.properties.liveRegion == true),
          isTrue,
        );
        final retry = find.text(l10n.retryAction);
        await tester.ensureVisible(retry);
        await tester.tap(retry);
        await tester.pumpAndSettle();
        expect(settings.requests, [false, false]);
        expect(settings.enabled, isFalse);
        expect(find.text(l10n.savedMealImagesDisabledBody), findsOneWidget);
        expect(find.text(l10n.savedMealImagesSaveFailed), findsNothing);
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(settings.enabled, isTrue);
        expect(settings.requests, [false, false, true]);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$language settings loading and load failure can retry', (
      tester,
    ) async {
      final source = StreamController<bool>();
      addTearDown(source.close);
      final settings = _FakeRetentionSettings()..source = source.stream;
      await tester.pumpWidget(
        _settingsApp(Locale(language), settings, scale: 2),
      );
      await tester.pump();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsPage)),
      );
      expect(find.text(l10n.savedMealImagesLoading), findsOneWidget);
      source.addError(StateError('synthetic load failure'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.savedMealImagesLoadFailed), findsOneWidget);
      settings.source = null;
      await tester.ensureVisible(find.text(l10n.retryAction));
      await tester.tap(find.text(l10n.retryAction));
      await tester.pumpAndSettle();
      expect(find.text(l10n.savedMealImagesEnabledBody), findsOneWidget);
      expect(settings.requests, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$language image loading and failure retry to image-free detail',
      (tester) async {
        final pending = Completer<RetainedMealImage?>();
        final repository = _FakeImageRepository(null)
          ..pendingLoad = pending.future;
        await tester.pumpWidget(
          _app(
            const MealDetailPage(mealId: 'meal-1'),
            imageRepository: repository,
            locale: Locale(language),
            scale: 2,
          ),
        );
        await tester.pump();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(MealDetailPage)),
        );
        expect(find.text(l10n.savedMealImageLoading), findsOneWidget);
        pending.completeError(StateError('synthetic load failure'));
        await tester.pumpAndSettle();
        expect(find.text(l10n.savedMealImageLoadFailed), findsOneWidget);
        repository.pendingLoad = null;
        final retry = find.byKey(const Key('retry-saved-image-button'));
        await tester.ensureVisible(retry);
        await tester.tap(retry);
        await tester.pumpAndSettle();
        expect(find.text(l10n.savedMealImageLoadFailed), findsNothing);
        expect(
          find.byKey(const Key('remove-saved-image-button')),
          findsNothing,
        );
        expect(find.text('Synthetic item'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$language image removal supports cancel and retry at 200%', (
      tester,
    ) async {
      final repository = _FakeImageRepository(_retained('meal-1'))
        ..failRemove = true;
      await tester.pumpWidget(
        _app(
          const MealDetailPage(mealId: 'meal-1'),
          imageRepository: repository,
          locale: Locale(language),
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(MealDetailPage)),
      );
      expect(find.bySemanticsLabel(l10n.savedMealImageLabel), findsOneWidget);
      final remove = find.byKey(const Key('remove-saved-image-button'));
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancelAction));
      await tester.pumpAndSettle();
      expect(repository.removeCalls, 0);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.removeSavedImageAction).last);
      await tester.pumpAndSettle();
      expect(find.text(l10n.removeSavedImageFailed), findsOneWidget);
      expect(repository.image, isNotNull);
      final retry = find.byKey(const Key('retry-remove-saved-image-button'));
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(repository.removeCalls, 2);
      expect(repository.image, isNull);
      expect(find.bySemanticsLabel(l10n.savedMealImageLabel), findsNothing);
      expect(find.text('Synthetic item'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('meal detail displays and confirms removal of a retained image', (
    tester,
  ) async {
    final imageRepository = _FakeImageRepository(_retained('meal-1'));
    await tester.pumpWidget(
      _app(
        const MealDetailPage(mealId: 'meal-1'),
        imageRepository: imageRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Saved meal image'), findsOneWidget);
    await tester.tap(find.byKey(const Key('remove-saved-image-button')));
    await tester.pumpAndSettle();
    expect(find.text('Remove saved meal image?'), findsOneWidget);
    expect(imageRepository.removeCalls, 0);

    await tester.tap(find.text('Remove saved image').last);
    await tester.pumpAndSettle();
    expect(imageRepository.removeCalls, 1);
    expect(find.bySemanticsLabel('Saved meal image'), findsNothing);
  });

  testWidgets('failed image removal preserves the image and offers retry', (
    tester,
  ) async {
    final imageRepository = _FakeImageRepository(_retained('meal-1'))
      ..failRemove = true;
    await tester.pumpWidget(
      _app(
        const MealDetailPage(mealId: 'meal-1'),
        imageRepository: imageRepository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('remove-saved-image-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove saved image').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('remove-saved-image-button')), findsOneWidget);
    expect(
      find.text(
        'The saved meal image could not be removed. It is still available.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('retry-remove-saved-image-button')),
      findsOneWidget,
    );
  });

  testWidgets('German settings confirms disabling retention', (tester) async {
    final settings = _FakeRetentionSettings();
    await tester.pumpWidget(_settingsApp(const Locale('de'), settings));
    await tester.pumpAndSettle();

    expect(find.text('Gespeicherte Essensbilder'), findsOneWidget);
    await tester.tap(find.byKey(const Key('retention-setting-switch')));
    await tester.pumpAndSettle();
    expect(
      find.text('Gespeicherte Essensbilder deaktivieren?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Deaktivieren und Bilder entfernen'));
    await tester.pumpAndSettle();

    expect(settings.enabled, isFalse);
    expect(
      find.text(
        'Deaktiviert. Neue und vorhandene gespeicherte Essensbilder wurden entfernt.',
      ),
      findsOneWidget,
    );
  });
}

Widget _app(
  Widget home, {
  required _FakeImageRepository imageRepository,
  Locale locale = const Locale('en'),
  double scale = 1,
}) => ProviderScope(
  overrides: [
    mealRepositoryProvider.overrideWithValue(_FakeMealRepository()),
    mealImageRepositoryProvider.overrideWithValue(imageRepository),
  ],
  child: MaterialApp(
    locale: locale,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

Widget _settingsApp(
  Locale locale,
  _FakeRetentionSettings settings, {
  double scale = 1,
}) => ProviderScope(
  overrides: [mealImageRetentionSettingsProvider.overrideWithValue(settings)],
  child: MaterialApp(
    locale: locale,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SettingsPage(),
  ),
);

RetainedMealImage _retained(String mealId) {
  final picture = image.Image(width: 2, height: 2)
    ..clear(image.ColorRgb8(40, 50, 60));
  return RetainedMealImage(
    mealId: mealId,
    jpegBytes: Uint8List.fromList(image.encodeJpg(picture, quality: 70)),
    width: 2,
    height: 2,
    mimeType: 'image/jpeg',
  );
}

class _FakeImageRepository implements MealImageRepository {
  _FakeImageRepository(this.image);

  RetainedMealImage? image;
  var removeCalls = 0;
  var failRemove = false;
  Future<RetainedMealImage?>? pendingLoad;

  @override
  Future<RetainedMealImage?> findByMealId(String mealId) async =>
      pendingLoad == null ? image : await pendingLoad;

  @override
  Future<void> removeForMeal(String mealId) async {
    removeCalls++;
    if (failRemove) {
      failRemove = false;
      throw StateError('synthetic failure');
    }
    image = null;
  }
}

class _FakeRetentionSettings implements MealImageRetentionSettings {
  var enabled = true;
  var failSave = false;
  final requests = <bool>[];
  Stream<bool>? source;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Stream<bool> observeEnabled() => source ?? Stream.value(enabled);

  @override
  Future<void> setEnabled(bool value) async {
    requests.add(value);
    if (failSave) {
      failSave = false;
      throw StateError('synthetic save failure');
    }
    enabled = value;
  }
}

class _FakeMealRepository implements MealRepository {
  @override
  Future<MealEntry> create(MealEntryDraft draft) => throw UnimplementedError();

  @override
  Future<MealEntry?> findById(String id, {bool includeDeleted = false}) async =>
      _entry();

  @override
  Stream<List<MealEntry>> observeDay(DateTime localDay) =>
      Stream.value([_entry()]);

  @override
  Stream<List<MealEntry>> observeRange(DateTime start, DateTime end) =>
      Stream.value([_entry()]);

  @override
  Future<MealEntry> restore({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();

  @override
  Future<MealEntry> softDelete({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();

  @override
  Future<MealEntry> update(MealEntry entry) => throw UnimplementedError();
}

MealEntry _entry() => MealEntry(
  id: 'meal-1',
  createdAtUtc: DateTime.utc(2026),
  updatedAtUtc: DateTime.utc(2026),
  revision: 0,
  occurredAtUtc: DateTime.utc(2026, 7, 18),
  occurredOffsetMinutes: 0,
  items: [
    MealItem(
      id: 'item-1',
      name: 'Synthetic item',
      nutrition: NutritionFacts(const {}),
      confidence: MealConfidence.medium,
    ),
  ],
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'fixture',
    analyzedAtUtc: DateTime.utc(2026),
    detectedLocale: 'en',
  ),
);
