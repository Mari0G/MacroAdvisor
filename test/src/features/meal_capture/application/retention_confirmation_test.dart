import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/image_meal_photo_normalizer.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_image_repository.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_repository.dart';

void main() {
  late AppDatabase database;
  late DriftMealImageRepository images;
  late ProviderContainer container;
  late _ProviderSpy provider;
  late _Normalizer normalizer;
  late Uint8List sourceBytes;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    images = DriftMealImageRepository(database);
    provider = _ProviderSpy();
    normalizer = _Normalizer();
    // Runtime-generated pixels and a synthetic source-only marker, never a file.
    sourceBytes = Uint8List.fromList([
      ...image.encodePng(image.Image(width: 800, height: 600)),
      ...utf8.encode(_sourceMarker),
    ]);
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(_Clock()),
        idGeneratorProvider.overrideWithValue(_Ids()),
        mealRepositoryProvider.overrideWithValue(
          DriftMealRepository(database, _Clock(), _Ids()),
        ),
        nutritionAnalysisProvider.overrideWithValue(provider),
        mealPhotoSourceProvider.overrideWithValue(_Source(sourceBytes)),
        mealPhotoNormalizerProvider.overrideWithValue(normalizer),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  for (final initiallyEnabled in [true, false]) {
    for (final pending in [false, true]) {
      test('confirmation uses latest setting: $initiallyEnabled -> '
          '${!initiallyEnabled}, candidate pending: $pending', () async {
        await images.setEnabled(initiallyEnabled);
        if (pending) normalizer.gate = Completer<void>();
        final photo = container.read(photoControllerProvider.notifier);
        await photo.chooseSource(MealPhotoSourceType.library);
        await photo.analyze('en');
        final review = container.read(reviewControllerProvider.notifier);
        expect(
          container.read(reviewControllerProvider).phase,
          ReviewPhase.reviewing,
        );
        expect(await database.select(database.mealEntries).get(), isEmpty);
        expect(
          await database.select(database.mealRetainedImages).get(),
          isEmpty,
        );

        if (pending) {
          final saving = review.save();
          expect(
            container.read(reviewControllerProvider).phase,
            ReviewPhase.saving,
          );
          await images.setEnabled(!initiallyEnabled);
          normalizer.gate!.complete();
          await saving;
        } else {
          await photo.readRetentionCandidate();
          await images.setEnabled(!initiallyEnabled);
          await review.save();
        }

        expect(
          container.read(reviewControllerProvider).phase,
          ReviewPhase.saved,
        );
        expect(await database.select(database.mealEntries).get(), hasLength(1));
        expect(await database.select(database.mealItems).get(), hasLength(1));
        expect(await images.isEnabled(), !initiallyEnabled);
        expect(
          await database.select(database.mealRetainedImages).get(),
          initiallyEnabled ? isEmpty : hasLength(1),
        );
      });
    }
  }

  test(
    'privacy: only confirmed derivative reaches its dedicated SQLite column',
    () async {
      final photo = container.read(photoControllerProvider.notifier);
      await photo.chooseSource(MealPhotoSourceType.camera);
      final normalized = container.read(photoControllerProvider).photo!;
      final candidate = (await photo.readRetentionCandidate())!;
      expect(candidate.width, 512);
      expect(candidate.jpegBytes, isNot(orderedEquals(normalized.jpegBytes)));
      expect(normalized.jpegBytes, isNot(orderedEquals(sourceBytes)));
      expect(
        latin1.decode(normalized.jpegBytes),
        isNot(contains(_sourceMarker)),
      );
      expect(
        latin1.decode(candidate.jpegBytes),
        isNot(contains(_sourceMarker)),
      );

      await photo.analyze('de');
      expect(provider.requests, hasLength(1));
      expect(provider.requests.single.photo, same(normalized));
      expect(provider.requests.single.localeTag, 'de');
      expect(container.read(photoControllerProvider).photo, isNull);
      expect(await database.select(database.mealRetainedImages).get(), isEmpty);
      expect(await database.select(database.mealEntries).get(), isEmpty);

      await container.read(reviewControllerProvider.notifier).save();
      expect(container.read(reviewControllerProvider).phase, ReviewPhase.saved);
      final retained = await database.select(database.mealRetainedImages).get();
      expect(retained, hasLength(1));
      expect(retained.single.jpegBytes, orderedEquals(candidate.jpegBytes));

      // Scan every persisted user-table value, including blobs and text fields.
      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      var blobCount = 0;
      for (final table in tables) {
        final name = table.read<String>('name');
        final rows = await database.customSelect('SELECT * FROM "$name"').get();
        for (final row in rows) {
          for (final cell in row.data.entries) {
            final value = cell.value;
            if (value is Uint8List) {
              blobCount++;
              expect(name, 'meal_retained_images');
              expect(cell.key, 'jpeg_bytes');
              expect(value, orderedEquals(candidate.jpegBytes));
              expect(value, isNot(orderedEquals(normalized.jpegBytes)));
              expect(latin1.decode(value), isNot(contains(_sourceMarker)));
            } else {
              final text = value.toString();
              expect(text, isNot(contains(_sourceMarker)));
              expect(text, isNot(contains(base64Encode(sourceBytes))));
              expect(text, isNot(contains(base64Encode(normalized.jpegBytes))));
              expect(text, isNot(contains(base64Encode(candidate.jpegBytes))));
            }
          }
        }
      }
      expect(blobCount, 1);
    },
  );
}

const _sourceMarker = 'SYNTHETIC_SOURCE_ONLY_PRIVACY_MARKER_2026';

class _Normalizer
    implements MealPhotoNormalizer, MealPhotoRetentionCandidateDeriver {
  final _delegate = ImageMealPhotoNormalizer();
  Completer<void>? gate;

  @override
  Future<MealPhoto> normalize(Uint8List sourceBytes) =>
      _delegate.normalize(sourceBytes);

  @override
  Future<MealPhotoRetentionCandidate> deriveRetentionCandidate(
    MealPhoto photo,
  ) async {
    if (gate != null) await gate!.future;
    return _delegate.deriveRetentionCandidate(photo);
  }
}

class _Source implements MealPhotoSource {
  _Source(this.bytes);
  final Uint8List bytes;
  @override
  Future<MealPhotoAcquisition> acquire(MealPhotoSourceType source) async =>
      AcquiredMealPhoto(bytes);
  @override
  Future<MealPhotoAcquisition?> recoverLostData() async => null;
}

class _ProviderSpy implements NutritionAnalysisProvider {
  final requests = <NutritionImageAnalysisRequest>[];

  @override
  Future<NutritionAnalysis> analyzeImage(
    NutritionImageAnalysisRequest request,
  ) async {
    requests.add(request);
    return NutritionAnalysis(
      provenance: MealProvenance(
        providerId: 'synthetic-provider',
        modelId: 'synthetic-model',
        analyzedAtUtc: DateTime.utc(2026, 9, 5),
        detectedLocale: request.localeTag,
      ),
      confidence: MealConfidence.medium,
      items: [
        MealItem(
          id: 'synthetic-item',
          name: 'Synthetic oats',
          nutrition: NutritionFacts({
            NutrientId.protein: const KnownNutritionValue(
              milliUnits: 12000,
              unit: NutritionUnit.grams,
              source: NutritionValueSource.providerEstimate,
            ),
          }),
          confidence: MealConfidence.medium,
        ),
      ],
    );
  }

  @override
  Future<NutritionAnalysis> analyzeText(NutritionAnalysisRequest request) =>
      throw UnimplementedError();
}

class _Clock implements Clock {
  @override
  DateTime now() => DateTime.utc(2026, 9, 5);
}

class _Ids implements IdGenerator {
  var next = 0;
  @override
  String newId() => 'synthetic-id-${++next}';
}
