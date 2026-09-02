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

Widget _app(Widget home, {required _FakeImageRepository imageRepository}) =>
    ProviderScope(
      overrides: [
        mealRepositoryProvider.overrideWithValue(_FakeMealRepository()),
        mealImageRepositoryProvider.overrideWithValue(imageRepository),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

Widget _settingsApp(Locale locale, _FakeRetentionSettings settings) =>
    ProviderScope(
      overrides: [
        mealImageRetentionSettingsProvider.overrideWithValue(settings),
      ],
      child: MaterialApp(
        locale: locale,
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

  @override
  Future<RetainedMealImage?> findByMealId(String mealId) async => image;

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

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Stream<bool> observeEnabled() => Stream.value(enabled);

  @override
  Future<void> setEnabled(bool value) async => enabled = value;
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
