import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_image.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_image_repository.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_repository.dart';

void main() {
  late AppDatabase database;
  late DriftMealRepository meals;
  late DriftMealImageRepository images;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    meals = DriftMealRepository(database, _Clock(), _Ids());
    images = DriftMealImageRepository(database);
  });

  tearDown(() => database.close());

  test('failed bulk deletion rolls back preference and every image', () async {
    for (final id in ['meal-1', 'meal-2']) {
      await meals.createWithRetainedImage(
        _draft(confirmationId: id),
        _retained(id),
      );
    }
    final before = await database
        .customSelect('SELECT * FROM meal_entries ORDER BY id')
        .get();
    await database.customStatement(
      "CREATE TRIGGER fail_media_delete BEFORE DELETE ON meal_retained_images BEGIN SELECT RAISE(ABORT, 'synthetic failure'); END",
    );
    await expectLater(images.setEnabled(false), throwsA(anything));
    expect(await images.isEnabled(), isTrue);
    expect(
      await database.select(database.mealRetainedImages).get(),
      hasLength(2),
    );
    expect(
      (await database
              .customSelect('SELECT * FROM meal_entries ORDER BY id')
              .get())
          .map((r) => r.data),
      before.map((r) => r.data),
    );
    await database.customStatement('DROP TRIGGER fail_media_delete');
    await images.setEnabled(false);
    expect(await images.isEnabled(), isFalse);
    expect(await database.select(database.mealRetainedImages).get(), isEmpty);
  });

  test(
    'defaults retention on and atomically stores one bounded image',
    () async {
      expect(await images.isEnabled(), isTrue);
      final saved = await meals.createWithRetainedImage(
        _draft(confirmationId: 'meal-1'),
        _retained('meal-1'),
      );

      final retained = await images.findByMealId(saved.id);
      expect(retained, isNotNull);
      expect(retained!.mealId, saved.id);
      expect(retained.mimeType, 'image/jpeg');
      expect(retained.width, lessThanOrEqualTo(512));
      expect(retained.height, lessThanOrEqualTo(512));
      expect(retained.jpegBytes.length, lessThanOrEqualTo(256 * 1024));
    },
  );

  test(
    'disabled retention saves nutrition without media and deletes all media',
    () async {
      await meals.createWithRetainedImage(
        _draft(confirmationId: 'meal-1'),
        _retained('meal-1'),
      );
      await images.setEnabled(false);

      expect(await images.isEnabled(), isFalse);
      expect(await images.findByMealId('meal-1'), isNull);
      final saved = await meals.createWithRetainedImage(
        _draft(confirmationId: 'meal-2'),
        _retained('meal-2'),
      );
      expect(await meals.findById(saved.id), isNotNull);
      expect(await images.findByMealId(saved.id), isNull);
    },
  );

  test(
    'soft deletion removes media and restoration does not recreate it',
    () async {
      final saved = await meals.createWithRetainedImage(
        _draft(confirmationId: 'meal-1'),
        _retained('meal-1'),
      );
      final deleted = await meals.softDelete(
        id: saved.id,
        expectedRevision: saved.revision,
      );
      expect(await images.findByMealId(saved.id), isNull);

      await meals.restore(id: saved.id, expectedRevision: deleted.revision);
      expect(await meals.findById(saved.id), isNotNull);
      expect(await images.findByMealId(saved.id), isNull);
    },
  );

  test(
    'invalid media rolls back the meal and a retry remains idempotent',
    () async {
      final invalid = RetainedMealImage(
        mealId: 'meal-1',
        jpegBytes: Uint8List.fromList([1, 2, 3]),
        width: 1,
        height: 1,
        mimeType: 'image/jpeg',
      );
      await expectLater(
        meals.createWithRetainedImage(
          _draft(confirmationId: 'meal-1'),
          invalid,
        ),
        throwsA(isA<MealImagePersistenceFailure>()),
      );
      expect(await meals.findById('meal-1'), isNull);
      expect(await images.findByMealId('meal-1'), isNull);

      final saved = await meals.createWithRetainedImage(
        _draft(confirmationId: 'meal-1'),
        _retained('meal-1'),
      );
      final retried = await meals.createWithRetainedImage(
        _draft(confirmationId: 'meal-1'),
        _retained('meal-1'),
      );
      expect(retried.id, saved.id);
      expect(await images.findByMealId('meal-1'), isNotNull);
    },
  );

  test('individual removal preserves the meal', () async {
    final saved = await meals.createWithRetainedImage(
      _draft(confirmationId: 'meal-1'),
      _retained('meal-1'),
    );
    await images.removeForMeal(saved.id);
    expect(await images.findByMealId(saved.id), isNull);
    expect(await meals.findById(saved.id), isNotNull);
  });
}

MealEntryDraft _draft({required String confirmationId}) => MealEntryDraft(
  occurredAtUtc: DateTime.utc(2026, 7, 18, 8),
  occurredOffsetMinutes: 120,
  description: 'Synthetic meal',
  confirmationId: confirmationId,
  items: [
    MealItem(
      id: '$confirmationId-item',
      name: 'Synthetic item',
      nutrition: NutritionFacts(const {}),
      confidence: MealConfidence.medium,
    ),
  ],
  provenance: MealProvenance(
    providerId: 'fake',
    modelId: 'fixture',
    analyzedAtUtc: DateTime.utc(2026, 7, 18),
    detectedLocale: 'en',
  ),
);

RetainedMealImage _retained(String mealId) {
  final picture = image.Image(width: 4, height: 3)
    ..clear(image.ColorRgb8(30, 40, 50));
  return RetainedMealImage(
    mealId: mealId,
    jpegBytes: Uint8List.fromList(image.encodeJpg(picture, quality: 70)),
    width: 4,
    height: 3,
    mimeType: 'image/jpeg',
  );
}

class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 7, 18, 10);
}

class _Ids implements IdGenerator {
  @override
  String newId() => 'generated-id';
}
