import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:integration_test/integration_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/infrastructure/drift_goal_repository.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/deterministic_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_image_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_image_repository.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_repository.dart';
import 'package:macro_advisor/src/features/settings/application/meal_image_retention_provider.dart';
import 'package:macro_advisor/src/features/settings/application/provider_settings_controller.dart';
import 'package:macro_advisor/src/features/settings/domain/credential_store.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/deterministic_connection_checker.dart';

/// Fast, repeatable Android smoke test for agents and CI.
///
/// It drives the production navigation and screens, but replaces the provider
/// network call and secure store with deterministic test seams. The meal still
/// passes through the real Drift repository, so confirmation proves that a
/// reviewed entry is locally persisted without requiring a real credential.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('saves, edits, moves, and restores a reviewed meal', (
    tester,
  ) async {
    final harness = _TestHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.app);
    await _advance(tester);

    await tester.tap(find.byTooltip('Open settings'));
    await _advance(tester);
    await tester.tap(find.text('Nutrition goals'));
    await _advance(tester);
    await tester.tap(find.text('Minimum').first);
    await _advance(tester);
    await tester.enterText(find.byType(TextFormField).first, '1800');
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-goals-button')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('save-goals-button')));
    await _advance(tester);
    await tester.pageBack();
    await _advance(tester);

    await tester.tap(find.byTooltip('Open settings'));
    await _advance(tester);
    await tester.tap(find.text('AI provider'));
    await _advance(tester);
    await tester.enterText(
      find.byKey(const Key('provider-credential-field')),
      'agent-fixture-key',
    );
    await tester.tap(find.byKey(const Key('save-credential-button')));
    await _advance(tester);
    await tester.tap(find.byKey(const Key('test-connection-button')));
    await _advance(tester);

    expect(find.text('Connection test succeeded.'), findsOneWidget);
    expect(find.text('agent-fixture-key'), findsNothing);

    await tester.pageBack();
    await _advance(tester);
    await tester.pageBack();
    await _advance(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await _waitFor(tester, find.byKey(const Key('describe-meal-source')));
    await tester.tap(find.byKey(const Key('describe-meal-source')));
    await _advance(tester);
    await tester.enterText(
      find.byKey(const Key('meal-description-field')),
      'Greek yogurt with banana and almonds',
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('analyze-meal-button')));
    await tester.tap(find.byKey(const Key('analyze-meal-button')));
    await _waitFor(tester, find.text('Review estimate'));

    expect(find.text('Review estimate'), findsOneWidget);
    expect(
      find.textContaining('A standard serving size was assumed.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('confirm-save-button')));
    await _advance(tester);

    final savedEntries = await harness.repository
        .observeDay(DateTime(2026, 7, 20))
        .first;
    expect(savedEntries, hasLength(1));
    final savedEntry = savedEntries.single;
    expect(savedEntry.description, 'Greek yogurt with banana and almonds');
    expect(
      savedEntry.items.single.name,
      'Greek yogurt with banana and almonds',
    );
    expect(harness.provider.calls, 1);
    expect(find.text('Meals and drinks (1)'), findsOneWidget);
    expect(find.text('450 kcal'), findsWidgets);
    expect(find.text('Progress toward goals'), findsOneWidget);
    expect(find.text('Below minimum'), findsOneWidget);

    await tester.tap(find.byTooltip('Open nutrition history'));
    await _advance(tester);
    expect(find.text('Nutrition history'), findsOneWidget);
    expect(find.text('Daily values'), findsOneWidget);
    await tester.pageBack();
    await _advance(tester);

    final savedMealFinder = find
        .text('Greek yogurt with banana and almonds')
        .first;
    await tester.ensureVisible(savedMealFinder);
    await tester.tap(savedMealFinder);
    await _advance(tester);
    expect(find.text('Saved meal'), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit-meal-button')));
    await _advance(tester);
    expect(find.text('Edit saved meal'), findsOneWidget);

    await tester.tap(
      find.byKey(Key('edit-meal-item-${savedEntry.items.single.id}')),
    );
    await _advance(tester);
    final energyField = find.byKey(const Key('item-nutrient-energy'));
    await tester.ensureVisible(energyField);
    await tester.enterText(energyField, '900');
    await tester.tap(find.byKey(const Key('save-item-button')));
    await _advance(tester);

    await tester.tap(find.byKey(const Key('meal-occurrence-button')));
    await _advance(tester);
    await tester.tap(find.text('19').last);
    await _advance(tester);
    await tester.tap(find.text('OK').last);
    await _advance(tester);
    await tester.tap(find.text('OK').last);
    await _advance(tester);

    await tester.tap(find.byKey(const Key('save-meal-button')));
    await _advance(tester);

    final revisedEntry = await harness.repository.findById(savedEntry.id);
    expect(revisedEntry, isNotNull);
    expect(revisedEntry!.revision, 1);
    expect(revisedEntry.userEdited, isTrue);
    expect(
      revisedEntry.items.single.nutrition[NutrientId.energy],
      isA<KnownNutritionValue>(),
    );
    expect(
      (revisedEntry.items.single.nutrition[NutrientId.energy]
              as KnownNutritionValue)
          .milliUnits,
      900000,
    );
    expect(revisedEntry.occursOnLocalDay(DateTime(2026, 7, 19)), isTrue);
    expect(revisedEntry.occursOnLocalDay(DateTime(2026, 7, 20)), isFalse);
    expect(harness.provider.calls, 1);

    await tester.pageBack();
    await _waitFor(tester, find.text('Meals and drinks (0)'));
    expect(find.text('No meals or drinks recorded'), findsOneWidget);

    final previousDayFinder = find.byTooltip('Previous day');
    await tester.ensureVisible(previousDayFinder);
    await tester.tap(previousDayFinder);
    await _waitFor(tester, find.text('Meals and drinks (1)'));
    expect(find.text('900 kcal'), findsWidgets);

    // Recreate the app with the same database to prove the revised entry is
    // persisted, rather than only reflected by the in-memory edit state.
    await tester.pumpWidget(harness.app);
    await _advance(tester);
    expect(find.text('Meals and drinks (0)'), findsOneWidget);
    expect(find.text('Progress toward goals'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous day'));
    await _waitFor(tester, find.text('Meals and drinks (1)'));
    expect(find.text('900 kcal'), findsWidgets);

    await tester.tap(find.text('Greek yogurt with banana and almonds').first);
    await _waitFor(tester, find.text('Saved meal'));
    await _waitFor(tester, find.textContaining('Revision 1'));
    expect(find.text('Edited'), findsOneWidget);
    expect(harness.provider.calls, 1);
  });

  testWidgets('library and camera photo meals retain bounded media', (
    tester,
  ) async {
    final harness = _TestHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.app);
    await _advance(tester);

    final sources = <Finder>[
      find.byKey(const Key('choose-photo-source')),
      find.byKey(const Key('take-photo-source')),
    ];
    for (var index = 0; index < sources.length; index++) {
      final source = sources[index];
      await tester.tap(find.text('Record meal').first);
      await _advance(tester);
      await tester.tap(source);
      await _waitFor(tester, find.text('Photo meal or drink'));
      final analyzeButton = find.byKey(const Key('analyze-photo-button')).last;
      await tester.scrollUntilVisible(
        analyzeButton,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(analyzeButton);
      await _waitFor(tester, find.text('Review estimate'));
      await tester.tap(find.byKey(const Key('confirm-save-button')));
      await _advance(tester);
      if (index < sources.length - 1) {
        await tester.pumpWidget(harness.app);
        await _advance(tester);
      }
    }

    final saved = await harness.repository
        .observeDay(DateTime(2026, 7, 20))
        .first;
    expect(saved, hasLength(2));
    expect(saved.map((entry) => entry.description), everyElement(isNull));
    for (final entry in saved) {
      final retained = await harness.images.findByMealId(entry.id);
      expect(retained, isNotNull);
      expect(retained!.mimeType, 'image/jpeg');
      expect(retained.width, lessThanOrEqualTo(512));
      expect(retained.height, lessThanOrEqualTo(512));
      expect(retained.jpegBytes.length, lessThanOrEqualTo(256 * 1024));
    }
    expect(harness.photoSource.sources, [
      MealPhotoSourceType.library,
      MealPhotoSourceType.camera,
    ]);
    expect(harness.provider.calls, 2);

    await tester.pumpWidget(harness.app);
    await _advance(tester);
    final restored = await harness.repository
        .observeDay(DateTime(2026, 7, 20))
        .first;
    expect(restored, hasLength(2));
    expect(restored.map((entry) => entry.description), everyElement(isNull));
    for (final entry in restored) {
      expect(await harness.images.findByMealId(entry.id), isNotNull);
    }
  });
}

Future<void> _advance(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 500));

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  expect(finder, findsOneWidget);
}

class _TestHarness {
  _TestHarness()
    : clock = _FixedClock(DateTime(2026, 7, 20, 12)),
      ids = _SequenceIdGenerator(),
      database = AppDatabase.forTesting(NativeDatabase.memory()),
      credentials = _InMemoryCredentialStore() {
    repository = DriftMealRepository(database, clock, ids);
    images = DriftMealImageRepository(database);
    provider = _CountingNutritionAnalysisProvider(
      DeterministicNutritionAnalysisProvider(clock, ids),
    );
  }

  final _FixedClock clock;
  final _SequenceIdGenerator ids;
  final AppDatabase database;
  final _InMemoryCredentialStore credentials;
  late final _CountingNutritionAnalysisProvider provider;
  late final DriftMealRepository repository;
  late final DriftMealImageRepository images;
  final photoSource = _TestPhotoSource();
  var _appVersion = 0;

  Widget get app => ProviderScope(
    key: ValueKey('test-app-${++_appVersion}'),
    overrides: [
      clockProvider.overrideWithValue(clock),
      idGeneratorProvider.overrideWithValue(ids),
      mealRepositoryProvider.overrideWithValue(repository),
      mealImageRepositoryProvider.overrideWithValue(images),
      mealImageRetentionSettingsProvider.overrideWithValue(images),
      goalRepositoryProvider.overrideWithValue(DriftGoalRepository(database)),
      credentialStoreProvider.overrideWithValue(credentials),
      providerConnectionCheckerProvider.overrideWithValue(
        const DeterministicConnectionChecker(),
      ),
      nutritionAnalysisProvider.overrideWithValue(provider),
      mealPhotoSourceProvider.overrideWithValue(photoSource),
      mealPhotoNormalizerProvider.overrideWithValue(_TestPhotoNormalizer()),
    ],
    child: const MacroAdvisorApp(locale: Locale('en')),
  );

  Future<void> dispose() => database.close();
}

class _CountingNutritionAnalysisProvider implements NutritionAnalysisProvider {
  _CountingNutritionAnalysisProvider(this._delegate);

  final NutritionAnalysisProvider _delegate;
  var calls = 0;

  @override
  Future<NutritionAnalysis> analyzeText(NutritionAnalysisRequest request) {
    calls++;
    return _delegate.analyzeText(request);
  }

  @override
  Future<NutritionAnalysis> analyzeImage(
    NutritionImageAnalysisRequest request,
  ) {
    calls++;
    return _delegate.analyzeImage(request);
  }
}

class _TestPhotoSource implements MealPhotoSource {
  final sources = <MealPhotoSourceType>[];

  @override
  Future<MealPhotoAcquisition> acquire(MealPhotoSourceType source) async {
    sources.add(source);
    final picture = image.Image(width: 1, height: 1)
      ..clear(image.ColorRgb8(0, 0, 0));
    return AcquiredMealPhoto(Uint8List.fromList(image.encodeJpg(picture)));
  }

  @override
  Future<MealPhotoAcquisition?> recoverLostData() async => null;
}

class _TestPhotoNormalizer
    implements MealPhotoNormalizer, MealPhotoRetentionCandidateDeriver {
  @override
  Future<MealPhoto> normalize(Uint8List sourceBytes) async =>
      MealPhoto(jpegBytes: sourceBytes, width: 1, height: 1);

  @override
  Future<MealPhotoRetentionCandidate> deriveRetentionCandidate(
    MealPhoto photo,
  ) async => MealPhotoRetentionCandidate(
    jpegBytes: photo.jpegBytes,
    width: photo.width,
    height: photo.height,
  );
}

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

class _SequenceIdGenerator implements IdGenerator {
  var _next = 0;

  @override
  String newId() => 'agent-test-${++_next}';
}

class _InMemoryCredentialStore implements CredentialStore {
  final Map<String, String> _credentials = {};

  @override
  Future<void> delete(String providerId) async {
    _credentials.remove(providerId);
  }

  @override
  Future<String?> read(String providerId) async => _credentials[providerId];

  @override
  Future<void> write({
    required String providerId,
    required String credential,
  }) async {
    _credentials[providerId] = credential;
  }
}
