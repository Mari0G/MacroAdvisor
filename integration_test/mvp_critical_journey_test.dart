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
import 'package:macro_advisor/src/features/meal_capture/infrastructure/deterministic_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
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

  testWidgets('tests a provider and creates a reviewed meal locally', (
    tester,
  ) async {
    final harness = _TestHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.app);
    await _advance(tester);

    await tester.tap(find.byTooltip('Open settings'));
    await _waitFor(tester, find.text('AI provider'));
    await tester.tap(find.text('AI provider'));
    await _waitFor(tester, find.byKey(const Key('provider-credential-field')));
    await tester.enterText(
      find.byKey(const Key('provider-credential-field')),
      'agent-fixture-key',
    );
    await tester.tap(find.byKey(const Key('save-credential-button')));
    await _waitFor(tester, find.byKey(const Key('test-connection-button')));
    await tester.tap(find.byKey(const Key('test-connection-button')));
    await _waitFor(tester, find.text('Connection test succeeded.'));

    expect(find.text('Connection test succeeded.'), findsOneWidget);
    expect(find.text('agent-fixture-key'), findsNothing);

    await _popTopRoute(tester);
    await _waitFor(tester, find.text('AI provider'));
    await _popTopRoute(tester);
    await _waitFor(tester, find.text('Record meal').first);

    await tester.tap(find.text('Record meal').first);
    await _waitFor(tester, find.byKey(const Key('meal-description-field')));
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
      findsWidgets,
    );

    await tester.tap(find.byKey(const Key('confirm-save-button')));
    await _waitFor(tester, find.text('Today'));

    final savedEntries = await harness.repository
        .observeDay(DateTime(2026, 7, 20))
        .first;
    expect(savedEntries, hasLength(1));
    expect(
      savedEntries.single.description,
      'Greek yogurt with banana and almonds',
    );
    expect(
      savedEntries.single.items.single.name,
      'Greek yogurt with banana and almonds',
    );

    await _waitFor(tester, find.text('Greek yogurt with banana and almonds'));
    await tester.tap(find.text('Greek yogurt with banana and almonds').first);
    await _advance(tester);
    expect(find.text('Saved meal'), findsOneWidget);
    expect(
      find.text(
        'This is a nutrition estimate, not a measurement. Review it before saving.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('edit-meal-button')));
    await _advance(tester);
    expect(find.text('Edit saved meal'), findsOneWidget);
    await tester.tap(find.byKey(const Key('save-meal-button')));
    await _advance(tester);

    final revised = await harness.repository.findById(
      savedEntries.single.id,
      includeDeleted: true,
    );
    expect(revised!.revision, 1);

    await tester.tap(find.byKey(const Key('delete-meal-button')));
    await _advance(tester);
    await tester.tap(find.text('Delete'));
    await _advance(tester);
    expect(
      await harness.repository.observeDay(DateTime(2026, 7, 20)).first,
      isEmpty,
    );
  });
}

Future<void> _advance(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 500));

Future<void> _popTopRoute(WidgetTester tester) async {
  final backButtons = find.byTooltip('Back');
  expect(backButtons, findsWidgets);
  await tester.tap(backButtons.last);
  await _advance(tester);
}

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
      database = AppDatabase(),
      credentials = _InMemoryCredentialStore() {
    repository = DriftMealRepository(database, clock, ids);
  }

  final _FixedClock clock;
  final _SequenceIdGenerator ids;
  final AppDatabase database;
  final _InMemoryCredentialStore credentials;
  late final DriftMealRepository repository;

  Widget get app => ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(clock),
      idGeneratorProvider.overrideWithValue(ids),
      mealRepositoryProvider.overrideWithValue(repository),
      credentialStoreProvider.overrideWithValue(credentials),
      providerConnectionCheckerProvider.overrideWithValue(
        const DeterministicConnectionChecker(),
      ),
      nutritionAnalysisProvider.overrideWithValue(
        DeterministicNutritionAnalysisProvider(clock, ids),
      ),
    ],
    child: const MacroAdvisorApp(locale: Locale('en')),
  );

  Future<void> dispose() => database.close();
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
