import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/deterministic_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_repository.dart';
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

    await tester.tap(find.text('Record meal').first);
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

    await tester.tap(find.text('Greek yogurt with banana and almonds').first);
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

    await tester.tap(find.byTooltip('Previous day'));
    await _waitFor(tester, find.text('Meals and drinks (1)'));
    expect(find.text('900 kcal'), findsWidgets);

    // Recreate the app with the same database to prove the revised entry is
    // persisted, rather than only reflected by the in-memory edit state.
    await tester.pumpWidget(harness.app);
    await _advance(tester);
    expect(find.text('Meals and drinks (0)'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous day'));
    await _waitFor(tester, find.text('Meals and drinks (1)'));
    expect(find.text('900 kcal'), findsWidgets);

    await tester.tap(find.text('Greek yogurt with banana and almonds').first);
    await _waitFor(tester, find.text('Saved meal'));
    await _waitFor(tester, find.textContaining('Revision 1'));
    expect(find.text('Edited'), findsOneWidget);
    expect(harness.provider.calls, 1);
  });
}

Future<void> _advance(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 500));

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final endTime = tester.binding.clock.fromNowBy(timeout);

  while (tester.binding.clock.now().isBefore(endTime)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
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
  var _appVersion = 0;

  Widget get app => ProviderScope(
    key: ValueKey('test-app-${++_appVersion}'),
    overrides: [
      clockProvider.overrideWithValue(clock),
      idGeneratorProvider.overrideWithValue(ids),
      mealRepositoryProvider.overrideWithValue(repository),
      credentialStoreProvider.overrideWithValue(credentials),
      providerConnectionCheckerProvider.overrideWithValue(
        const DeterministicConnectionChecker(),
      ),
      nutritionAnalysisProvider.overrideWithValue(provider),
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
