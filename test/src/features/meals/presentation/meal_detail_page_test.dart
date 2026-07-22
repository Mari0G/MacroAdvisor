import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/presentation/meal_detail_page.dart';

void main() {
  testWidgets('shows saved meal transparency and confirms delete', (
    tester,
  ) async {
    final repository = _FakeMealRepository(_entry());
    await tester.pumpWidget(
      _app(repository, const MealDetailPage(mealId: 'meal-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beans').first, findsOneWidget);
    expect(find.textContaining('Revision 2'), findsOneWidget);
    expect(
      find.text(
        'This is a nutrition estimate, not a measurement. Review it before saving.',
      ),
      findsOneWidget,
    );
    expect(find.text('Recalculated totals'), findsOneWidget);
    expect(find.text('Estimate provenance'), findsOneWidget);
    expect(find.text('Incomplete data'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-meal-button')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this meal?'), findsOneWidget);
    expect(
      find.textContaining('"Beans" will be removed from your daily totals.'),
      findsOneWidget,
    );
    expect(repository.deleteCalls, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this meal?'), findsNothing);
  });

  testWidgets('saved-meal edit persists revised values without analysis', (
    tester,
  ) async {
    final repository = _FakeMealRepository(_entry());
    await tester.pumpWidget(
      _app(repository, const MealEditPage(mealId: 'meal-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit saved meal'), findsOneWidget);
    await tester.tap(find.byKey(const Key('save-meal-button')));
    await tester.pumpAndSettle();

    expect(repository.updated, isNotNull);
  });

  testWidgets('shows a recoverable delete failure', (tester) async {
    final repository = _FakeMealRepository(_entry())..failDelete = true;
    await tester.pumpWidget(
      _app(repository, const MealDetailPage(mealId: 'meal-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete-meal-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(
      find.text('The meal could not be deleted. Your entry is still safe.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('retry-delete-button')), findsOneWidget);
  });
}

Widget _app(MealRepository repository, Widget home) => ProviderScope(
  overrides: [mealRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

class _FakeMealRepository implements MealRepository {
  _FakeMealRepository(this.entry);

  final MealEntry entry;
  MealEntry? updated;
  var deleteCalls = 0;
  var failDelete = false;

  @override
  Future<MealEntry> create(MealEntryDraft draft) => throw UnimplementedError();

  @override
  Future<MealEntry?> findById(String id, {bool includeDeleted = false}) async =>
      id == entry.id ? entry : null;

  @override
  Stream<List<MealEntry>> observeDay(DateTime localDay) =>
      Stream.value(<MealEntry>[entry]);

  @override
  Future<MealEntry> update(MealEntry value) async {
    updated = value;
    return value;
  }

  @override
  Future<MealEntry> softDelete({
    required String id,
    required int expectedRevision,
  }) async {
    deleteCalls++;
    if (failDelete) {
      failDelete = false;
      throw StateError('delete failed');
    }
    return entry;
  }

  @override
  Future<MealEntry> restore({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();
}

MealEntry _entry() => MealEntry(
  id: 'meal-1',
  createdAtUtc: DateTime.utc(2026, 3, 29),
  updatedAtUtc: DateTime.utc(2026, 3, 29),
  revision: 2,
  occurredAtUtc: DateTime.utc(2026, 3, 29, 10),
  occurredOffsetMinutes: 120,
  description: 'Beans',
  items: [
    MealItem(
      id: 'item-1',
      name: 'Beans',
      nutrition: NutritionFacts({
        NutrientId.energy: const KnownNutritionValue(
          milliUnits: 250000,
          unit: NutritionUnit.kilocalories,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
      confidence: MealConfidence.medium,
    ),
  ],
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'test-model',
    analyzedAtUtc: DateTime.utc(2026, 3, 29),
    detectedLocale: 'en',
  ),
);
