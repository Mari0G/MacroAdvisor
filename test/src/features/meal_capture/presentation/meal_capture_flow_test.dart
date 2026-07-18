import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/deterministic_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';

void main() {
  testWidgets('English user can review, edit, and save a text estimate', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(_app(const Locale('en'), repository));

    await tester.tap(find.text('Record meal').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('meal-description-field')),
      'Beans on toast',
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('analyze-meal-button')));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('analyze-meal-button')))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const Key('analyze-meal-button')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Review estimate'), findsOneWidget);
    expect(
      find.text(
        'This is a nutrition estimate, not a measurement. Review it before saving.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('confirm-save-button')));
    await tester.pumpAndSettle();

    expect(repository.created, hasLength(1));
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets(
    'German description form is localized and whitespace cannot submit',
    (tester) async {
      await tester.pumpWidget(_app(const Locale('de'), _Repository()));
      await tester.tap(find.text('Mahlzeit erfassen').first);
      await tester.pumpAndSettle();

      expect(find.text('Mahlzeit oder Getränk beschreiben'), findsOneWidget);
      expect(find.text('Schätzung analysieren'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('meal-description-field')),
        '   ',
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('analyze-meal-button')))
            .onPressed,
        isNull,
      );
    },
  );
}

Widget _app(Locale locale, _Repository repository) {
  final clock = _Clock(DateTime(2026, 7, 18, 12));
  final ids = _Ids();
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(clock),
      idGeneratorProvider.overrideWithValue(ids),
      mealRepositoryProvider.overrideWithValue(repository),
      nutritionAnalysisProvider.overrideWithValue(
        DeterministicNutritionAnalysisProvider(clock, ids),
      ),
    ],
    child: MacroAdvisorApp(locale: locale),
  );
}

class _Repository implements MealRepository {
  final created = <MealEntryDraft>[];
  @override
  Future<MealEntry> create(MealEntryDraft draft) async {
    created.add(draft);
    return MealEntry(
      id: draft.confirmationId!,
      createdAtUtc: DateTime.utc(2026),
      updatedAtUtc: DateTime.utc(2026),
      revision: 0,
      occurredAtUtc: draft.occurredAtUtc,
      occurredOffsetMinutes: draft.occurredOffsetMinutes,
      items: draft.items,
      provenance: draft.provenance,
    );
  }

  @override
  Future<MealEntry?> findById(String id, {bool includeDeleted = false}) async =>
      null;
  @override
  Stream<List<MealEntry>> observeDay(DateTime localDay) => Stream.value([]);
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

class _Clock implements Clock {
  const _Clock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

class _Ids implements IdGenerator {
  int _next = 0;
  @override
  String newId() => 'id-${++_next}';
}
