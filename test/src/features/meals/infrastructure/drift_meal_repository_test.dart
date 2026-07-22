import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_repository.dart';

void main() {
  group('DriftMealRepository contract', () {
    late AppDatabase database;
    late DriftMealRepository repository;
    late FixedClock clock;

    setUp(() {
      clock = FixedClock(DateTime.utc(2026, 7, 18, 10));
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftMealRepository(database, clock, SequenceIdGenerator());
    });

    tearDown(() => database.close());

    test(
      'creates an observable entry with deterministic identity and times',
      () async {
        final saved = await repository.create(_draft());

        expect(saved.id, 'id-1');
        expect(saved.createdAtUtc, clock.now());
        expect(
          (saved.totals[NutrientId.protein] as KnownNutritionValue).milliUnits,
          25000,
        );
        expect(await repository.findById(saved.id), isNotNull);
        expect(
          await repository.observeDay(DateTime(2026, 7, 18)).first,
          hasLength(1),
        );
      },
    );

    test(
      'returns an existing entry for a retried confirmation identifier',
      () async {
        final first = await repository.create(
          _draft(confirmationId: 'confirm-1'),
        );
        final retried = await repository.create(
          _draft(confirmationId: 'confirm-1'),
        );

        expect(retried.id, first.id);
        expect(
          await repository.observeDay(DateTime(2026, 7, 18)).first,
          hasLength(1),
        );
      },
    );

    test('updates atomically and rejects stale revisions', () async {
      final saved = await repository.create(_draft());
      clock.value = DateTime.utc(2026, 7, 18, 11);
      final updated = await repository.update(
        MealEntry(
          id: saved.id,
          createdAtUtc: saved.createdAtUtc,
          updatedAtUtc: saved.updatedAtUtc,
          revision: saved.revision,
          occurredAtUtc: saved.occurredAtUtc,
          occurredOffsetMinutes: saved.occurredOffsetMinutes,
          items: [_item(name: 'Updated item', proteinMilli: 30000)],
          provenance: saved.provenance,
          userEdited: true,
        ),
      );

      expect(updated.revision, 1);
      expect(updated.updatedAtUtc, clock.now());
      expect(
        (await repository.findById(saved.id))!.items.single.name,
        'Updated item',
      );
      await expectLater(
        repository.update(saved),
        throwsA(isA<MealRevisionConflict>()),
      );
    });

    test('soft-deletes and restores while incrementing revision', () async {
      final saved = await repository.create(_draft());
      clock.value = DateTime.utc(2026, 7, 18, 11);
      final deleted = await repository.softDelete(
        id: saved.id,
        expectedRevision: saved.revision,
      );

      expect(deleted.deletedAtUtc, clock.now());
      expect(deleted.revision, 1);
      expect(await repository.findById(saved.id), isNull);
      expect(await repository.observeDay(DateTime(2026, 7, 18)).first, isEmpty);

      final restored = await repository.restore(
        id: saved.id,
        expectedRevision: deleted.revision,
      );
      expect(restored.deletedAtUtc, isNull);
      expect(restored.revision, 2);
    });

    test(
      'preserves the recorded occurrence offset when selecting a local day',
      () async {
        await repository.create(
          _draft(
            occurredAtUtc: DateTime.utc(2026, 7, 17, 22, 30),
            occurredOffsetMinutes: 120,
          ),
        );

        expect(
          await repository.observeDay(DateTime(2026, 7, 18)).first,
          hasLength(1),
        );
        expect(
          await repository.observeDay(DateTime(2026, 7, 17)).first,
          isEmpty,
        );
      },
    );

    test('moves an updated entry between local days', () async {
      final saved = await repository.create(_draft());
      final moved = await repository.update(
        MealEntry(
          id: saved.id,
          createdAtUtc: saved.createdAtUtc,
          updatedAtUtc: saved.updatedAtUtc,
          revision: saved.revision,
          occurredAtUtc: DateTime.utc(2026, 7, 19, 8),
          occurredOffsetMinutes: saved.occurredOffsetMinutes,
          description: saved.description,
          items: saved.items,
          provenance: saved.provenance,
          userEdited: true,
          confidence: saved.confidence,
          assumptions: saved.assumptions,
        ),
      );

      expect(moved.revision, saved.revision + 1);
      expect(await repository.observeDay(DateTime(2026, 7, 18)).first, isEmpty);
      expect(
        await repository.observeDay(DateTime(2026, 7, 19)).first,
        hasLength(1),
      );
    });
  });

  test('version 1 schema is created and persists after reopening', () async {
    final directory = await Directory.systemTemp.createTemp(
      'macro_advisor_db_',
    );
    final file = File('${directory.path}${Platform.pathSeparator}meal.sqlite');
    final clock = FixedClock(DateTime.utc(2026, 7, 18, 10));
    final firstDatabase = AppDatabase.forTesting(NativeDatabase(file));
    final firstRepository = DriftMealRepository(
      firstDatabase,
      clock,
      SequenceIdGenerator(),
    );
    final created = await firstRepository.create(_draft());
    final version = await firstDatabase
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 1);
    await firstDatabase.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    final reopenedRepository = DriftMealRepository(
      reopened,
      clock,
      SequenceIdGenerator(),
    );
    expect(
      (await reopenedRepository.findById(created.id))!.items.single.name,
      'Beans',
    );
    await reopened.close();
    await directory.delete(recursive: true);
  });
}

MealEntryDraft _draft({
  DateTime? occurredAtUtc,
  int occurredOffsetMinutes = 120,
  String? confirmationId,
}) => MealEntryDraft(
  occurredAtUtc: occurredAtUtc ?? DateTime.utc(2026, 7, 18, 8),
  occurredOffsetMinutes: occurredOffsetMinutes,
  description: 'Beans on toast',
  confirmationId: confirmationId,
  items: [_item()],
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'deterministic',
    analyzedAtUtc: DateTime.utc(2026, 7, 18, 8),
    detectedLocale: 'en',
  ),
);

MealItem _item({String name = 'Beans', int proteinMilli = 25000}) => MealItem(
  id: 'item-1',
  name: name,
  normalizedGramsMilli: 150000,
  nutrition: NutritionFacts({
    NutrientId.protein: KnownNutritionValue(
      milliUnits: proteinMilli,
      unit: NutritionUnit.grams,
      source: NutritionValueSource.providerEstimate,
    ),
    NutrientId.energy: const UnknownNutritionValue(
      unit: NutritionUnit.kilocalories,
      source: NutritionValueSource.providerEstimate,
    ),
  }),
  confidence: MealConfidence.medium,
  assumptions: const [MealAssumption(code: 'portion', description: 'One bowl')],
);

class FixedClock implements Clock {
  FixedClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;
}

class SequenceIdGenerator implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'id-${++_next}';
}
