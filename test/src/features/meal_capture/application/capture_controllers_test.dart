import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  late _FakeMealRepository repository;
  late _Provider provider;
  late _PhotoSource photoSource;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeMealRepository();
    provider = _Provider();
    photoSource = _PhotoSource();
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(_FixedClock(DateTime(2026, 7, 18, 12))),
        idGeneratorProvider.overrideWithValue(_Ids()),
        mealRepositoryProvider.overrideWithValue(repository),
        nutritionAnalysisProvider.overrideWithValue(provider),
        mealPhotoSourceProvider.overrideWithValue(photoSource),
        mealPhotoNormalizerProvider.overrideWithValue(_PhotoNormalizer()),
      ],
    );
  });

  tearDown(() => container.dispose());

  test(
    'description preserves input and exposes a validated review estimate',
    () async {
      final controller = container.read(descriptionControllerProvider.notifier);
      controller.updateDescription('  Beans on toast  ');

      await controller.analyze('en');

      final state = container.read(descriptionControllerProvider);
      expect(state.description, '  Beans on toast  ');
      expect(state.phase, DescriptionPhase.readyForReview);
      expect(state.analysis!.items.single.name, 'Beans');
    },
  );

  test(
    'editing immediately recalculates totals and save is idempotent',
    () async {
      final description = container.read(
        descriptionControllerProvider.notifier,
      );
      description.updateDescription('Beans');
      await description.analyze('en');
      final review = container.read(reviewControllerProvider.notifier);
      final item = container.read(reviewControllerProvider).items.single;
      final editor = ItemEditController(ItemEditState(item: item), review);
      expect(
        editor.save(
          name: 'Edited beans',
          nutrition: _item(item.id, protein: 30000).nutrition.values,
        ),
        isTrue,
      );

      expect(
        (container.read(reviewControllerProvider).totals[NutrientId.protein]
                as KnownNutritionValue)
            .milliUnits,
        30000,
      );
      expect(
        container.read(reviewControllerProvider).items.single.name,
        'Edited beans',
      );
      await review.save();
      await review.save();

      expect(container.read(reviewControllerProvider).phase, ReviewPhase.saved);
      expect(repository.created, hasLength(1));
      expect(repository.created.single.confirmationId, 'id-1');
    },
  );

  test('save failure keeps the reviewed draft for retry', () async {
    repository.shouldFail = true;
    final description = container.read(descriptionControllerProvider.notifier);
    description.updateDescription('Beans');
    await description.analyze('en');

    await container.read(reviewControllerProvider.notifier).save();

    expect(
      container.read(reviewControllerProvider).phase,
      ReviewPhase.saveFailure,
    );
    expect(container.read(reviewControllerProvider).items, hasLength(1));
  });

  test(
    'provider timeout preserves the description and can be retried',
    () async {
      provider.timeoutFirstRequest = true;
      final controller = container.read(descriptionControllerProvider.notifier);
      controller.updateDescription('Beans on toast');

      await controller.analyze('en');

      final failureState = container.read(descriptionControllerProvider);
      expect(failureState.phase, DescriptionPhase.failure);
      expect(failureState.failure, isA<AnalysisTimedOut>());
      expect(failureState.description, 'Beans on toast');

      await controller.analyze('en');

      expect(
        container.read(descriptionControllerProvider).phase,
        DescriptionPhase.readyForReview,
      );
      expect(provider.calls, 2);
    },
  );

  test('cancelled photo selection is neutral', () async {
    photoSource.next = const CancelledMealPhotoAcquisition();

    await container
        .read(photoControllerProvider.notifier)
        .chooseSource(MealPhotoSourceType.library);

    final state = container.read(photoControllerProvider);
    expect(state.phase, PhotoPhase.chooser);
    expect(state.photo, isNull);
    expect(state.failure, isNull);
  });

  test(
    'photo analysis releases media before the shared review and save path',
    () async {
      photoSource.next = AcquiredMealPhoto(Uint8List.fromList([1, 2, 3]));
      final photo = container.read(photoControllerProvider.notifier);

      await photo.chooseSource(MealPhotoSourceType.camera);
      expect(container.read(photoControllerProvider).phase, PhotoPhase.preview);
      await photo.analyze('en');

      expect(
        container.read(photoControllerProvider).phase,
        PhotoPhase.readyForReview,
      );
      expect(container.read(photoControllerProvider).photo, isNull);
      final review = container.read(reviewControllerProvider.notifier);
      expect(container.read(reviewControllerProvider).items, hasLength(1));
      await review.save();

      expect(repository.created.single.description, isNull);
      expect(repository.created.single.items.single.name, 'Beans');
    },
  );
}

class _Provider implements NutritionAnalysisProvider {
  bool timeoutFirstRequest = false;
  int calls = 0;

  @override
  Future<NutritionAnalysis> analyzeText(
    NutritionAnalysisRequest request,
  ) async {
    calls++;
    if (timeoutFirstRequest && calls == 1) {
      throw const AnalysisTimedOut();
    }
    return NutritionAnalysis(
      provenance: MealProvenance(
        providerId: 'fake',
        modelId: 'fixture',
        analyzedAtUtc: DateTime.utc(2026, 7, 18),
        detectedLocale: request.localeTag,
      ),
      confidence: MealConfidence.medium,
      items: [_item('item-1')],
    );
  }

  @override
  Future<NutritionAnalysis> analyzeImage(
    NutritionImageAnalysisRequest request,
  ) => analyzeText(
    NutritionAnalysisRequest(
      description: 'Photo meal',
      localeTag: request.localeTag,
    ),
  );
}

class _PhotoSource implements MealPhotoSource {
  MealPhotoAcquisition next = const CancelledMealPhotoAcquisition();

  @override
  Future<MealPhotoAcquisition> acquire(MealPhotoSourceType source) async =>
      next;

  @override
  Future<MealPhotoAcquisition?> recoverLostData() async => null;
}

class _PhotoNormalizer implements MealPhotoNormalizer {
  @override
  Future<MealPhoto> normalize(Uint8List sourceBytes) async =>
      MealPhoto(jpegBytes: Uint8List.fromList([1, 2, 3]), width: 1, height: 1);
}

MealItem _item(String id, {int protein = 20000}) => MealItem(
  id: id,
  name: 'Beans',
  nutrition: NutritionFacts({
    NutrientId.protein: KnownNutritionValue(
      milliUnits: protein,
      unit: NutritionUnit.grams,
      source: NutritionValueSource.providerEstimate,
    ),
  }),
  confidence: MealConfidence.medium,
);

class _FakeMealRepository implements MealRepository {
  bool shouldFail = false;
  final created = <MealEntryDraft>[];

  @override
  Future<MealEntry> create(MealEntryDraft draft) async {
    if (shouldFail) throw StateError('save failed');
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
  Stream<List<MealEntry>> observeRange(DateTime start, DateTime end) =>
      Stream.value([]);
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

class _FixedClock implements Clock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

class _Ids implements IdGenerator {
  int _next = 0;
  @override
  String newId() => 'id-${++_next}';
}
