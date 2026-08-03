import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

enum DescriptionPhase { editing, analyzing, failure, readyForReview }

class DescriptionState {
  const DescriptionState({
    required this.description,
    required this.occurredAt,
    this.phase = DescriptionPhase.editing,
    this.failure,
    this.analysis,
  });

  final String description;
  final DateTime occurredAt;
  final DescriptionPhase phase;
  final NutritionAnalysisFailure? failure;
  final NutritionAnalysis? analysis;

  bool get hasDraft => description.trim().isNotEmpty;
  bool get canSubmit => hasDraft && phase != DescriptionPhase.analyzing;

  DescriptionState copyWith({
    String? description,
    DateTime? occurredAt,
    DescriptionPhase? phase,
    NutritionAnalysisFailure? failure,
    NutritionAnalysis? analysis,
    bool clearFailure = false,
    bool clearAnalysis = false,
  }) => DescriptionState(
    description: description ?? this.description,
    occurredAt: occurredAt ?? this.occurredAt,
    phase: phase ?? this.phase,
    failure: clearFailure ? null : failure ?? this.failure,
    analysis: clearAnalysis ? null : analysis ?? this.analysis,
  );
}

class DescriptionController extends Notifier<DescriptionState> {
  int _requestVersion = 0;

  @override
  DescriptionState build() => DescriptionState(
    description: '',
    occurredAt: ref.read(clockProvider).now(),
  );

  void updateDescription(String description) {
    if (state.phase == DescriptionPhase.analyzing) {
      return;
    }
    state = state.copyWith(
      description: description,
      phase: DescriptionPhase.editing,
      clearFailure: true,
      clearAnalysis: true,
    );
  }

  void updateOccurredAt(DateTime occurredAt) {
    if (state.phase == DescriptionPhase.analyzing) {
      return;
    }
    state = state.copyWith(occurredAt: occurredAt);
  }

  Future<void> analyze(String localeTag) async {
    final description = state.description.trim();
    if (description.isEmpty || state.phase == DescriptionPhase.analyzing) {
      return;
    }
    final version = ++_requestVersion;
    state = state.copyWith(
      phase: DescriptionPhase.analyzing,
      clearFailure: true,
      clearAnalysis: true,
    );
    try {
      final analysis = await ref
          .read(nutritionAnalysisProvider)
          .analyzeText(
            NutritionAnalysisRequest(
              description: description,
              localeTag: localeTag,
            ),
          );
      if (version != _requestVersion) {
        return;
      }
      state = state.copyWith(
        phase: DescriptionPhase.readyForReview,
        analysis: analysis,
      );
    } on NutritionAnalysisFailure catch (failure) {
      if (version != _requestVersion) {
        return;
      }
      state = state.copyWith(phase: DescriptionPhase.failure, failure: failure);
    } catch (_) {
      if (version != _requestVersion) {
        return;
      }
      state = state.copyWith(
        phase: DescriptionPhase.failure,
        failure: const UnknownAnalysisFailure(),
      );
    }
  }

  void cancelAnalysis() {
    if (state.phase != DescriptionPhase.analyzing) return;
    _requestVersion++;
    state = state.copyWith(phase: DescriptionPhase.editing);
  }

  void reset() {
    _requestVersion++;
    state = DescriptionState(
      description: '',
      occurredAt: ref.read(clockProvider).now(),
    );
  }
}

final descriptionControllerProvider =
    NotifierProvider<DescriptionController, DescriptionState>(
      DescriptionController.new,
    );

enum PhotoPhase {
  chooser,
  preparing,
  preview,
  analyzing,
  failure,
  readyForReview,
}

class PhotoState {
  const PhotoState({
    required this.occurredAt,
    this.phase = PhotoPhase.chooser,
    this.photo,
    this.failure,
    this.analysis,
  });

  final DateTime occurredAt;
  final PhotoPhase phase;
  final MealPhoto? photo;
  final Object? failure;
  final NutritionAnalysis? analysis;

  bool get hasPhoto => photo != null;
  bool get canAnalyze =>
      hasPhoto &&
      (phase == PhotoPhase.preview ||
          (phase == PhotoPhase.failure && failure is NutritionAnalysisFailure));

  PhotoState copyWith({
    DateTime? occurredAt,
    PhotoPhase? phase,
    MealPhoto? photo,
    Object? failure,
    NutritionAnalysis? analysis,
    bool clearPhoto = false,
    bool clearFailure = false,
    bool clearAnalysis = false,
  }) => PhotoState(
    occurredAt: occurredAt ?? this.occurredAt,
    phase: phase ?? this.phase,
    photo: clearPhoto ? null : photo ?? this.photo,
    failure: clearFailure ? null : failure ?? this.failure,
    analysis: clearAnalysis ? null : analysis ?? this.analysis,
  );
}

class PhotoController extends Notifier<PhotoState> {
  var _requestVersion = 0;

  @override
  PhotoState build() => PhotoState(occurredAt: ref.read(clockProvider).now());

  Future<void> recoverLostPickerData() async {
    if (state.phase != PhotoPhase.chooser) return;
    final recovered = await ref.read(mealPhotoSourceProvider).recoverLostData();
    if (recovered != null) await _prepare(recovered);
  }

  Future<void> chooseSource(MealPhotoSourceType source) async {
    if (state.phase == PhotoPhase.preparing ||
        state.phase == PhotoPhase.analyzing) {
      return;
    }
    final retainsPreview = state.photo != null;
    state = state.copyWith(
      phase: PhotoPhase.preparing,
      clearFailure: true,
      clearAnalysis: true,
    );
    await _prepare(
      await ref.read(mealPhotoSourceProvider).acquire(source),
      retainsPreview: retainsPreview,
    );
  }

  Future<void> _prepare(
    MealPhotoAcquisition acquisition, {
    bool retainsPreview = false,
  }) async {
    switch (acquisition) {
      case CancelledMealPhotoAcquisition():
        state = state.copyWith(
          phase: retainsPreview ? PhotoPhase.preview : PhotoPhase.chooser,
          clearFailure: true,
        );
      case FailedMealPhotoAcquisition(:final failure):
        state = state.copyWith(
          phase: retainsPreview ? PhotoPhase.preview : PhotoPhase.failure,
          failure: failure,
        );
      case AcquiredMealPhoto(:final bytes):
        final version = ++_requestVersion;
        state = state.copyWith(phase: PhotoPhase.preparing, clearFailure: true);
        try {
          final photo = await ref
              .read(mealPhotoNormalizerProvider)
              .normalize(bytes);
          if (version != _requestVersion) return;
          state = state.copyWith(
            phase: PhotoPhase.preview,
            photo: photo,
            clearFailure: true,
            clearAnalysis: true,
          );
        } on MealPhotoFailure catch (failure) {
          if (version != _requestVersion) return;
          state = state.copyWith(
            phase: PhotoPhase.failure,
            failure: failure,
            clearPhoto: true,
          );
        } catch (_) {
          if (version != _requestVersion) return;
          state = state.copyWith(
            phase: PhotoPhase.failure,
            failure: const UnreadableMealPhoto(),
            clearPhoto: true,
          );
        }
    }
  }

  void updateOccurredAt(DateTime occurredAt) {
    if (state.phase == PhotoPhase.analyzing) return;
    state = state.copyWith(occurredAt: occurredAt);
  }

  Future<void> analyze(String localeTag) async {
    final photo = state.photo;
    if (photo == null || state.phase != PhotoPhase.preview) return;
    final version = ++_requestVersion;
    state = state.copyWith(
      phase: PhotoPhase.analyzing,
      clearFailure: true,
      clearAnalysis: true,
    );
    try {
      final analysis = await ref
          .read(nutritionAnalysisProvider)
          .analyzeImage(
            NutritionImageAnalysisRequest(photo: photo, localeTag: localeTag),
          );
      if (version != _requestVersion) return;
      state = state.copyWith(
        phase: PhotoPhase.readyForReview,
        analysis: analysis,
        clearPhoto: true,
      );
    } on NutritionAnalysisFailure catch (failure) {
      if (version != _requestVersion) return;
      state = state.copyWith(phase: PhotoPhase.failure, failure: failure);
    } catch (_) {
      if (version != _requestVersion) return;
      state = state.copyWith(
        phase: PhotoPhase.failure,
        failure: const UnknownAnalysisFailure(),
      );
    }
  }

  void cancelAnalysis() {
    if (state.phase != PhotoPhase.analyzing) return;
    _requestVersion++;
    state = state.copyWith(phase: PhotoPhase.preview);
  }

  void discard() {
    _requestVersion++;
    state = PhotoState(occurredAt: ref.read(clockProvider).now());
  }
}

final photoControllerProvider = NotifierProvider<PhotoController, PhotoState>(
  PhotoController.new,
);

enum ReviewPhase { unavailable, reviewing, saving, saveFailure, saved }

class ReviewState {
  const ReviewState({
    required this.phase,
    this.description,
    this.occurredAt,
    this.analysis,
    this.items = const [],
    this.userEdited = false,
  });

  final ReviewPhase phase;
  final String? description;
  final DateTime? occurredAt;
  final NutritionAnalysis? analysis;
  final List<MealItem> items;
  final bool userEdited;

  bool get canSave => phase == ReviewPhase.reviewing && items.isNotEmpty;
  NutritionFacts get totals =>
      NutritionFacts.sum(items.map((item) => item.nutrition));

  ReviewState copyWith({
    ReviewPhase? phase,
    DateTime? occurredAt,
    List<MealItem>? items,
    bool? userEdited,
  }) => ReviewState(
    phase: phase ?? this.phase,
    description: description,
    occurredAt: occurredAt ?? this.occurredAt,
    analysis: analysis,
    items: List.unmodifiable(items ?? this.items),
    userEdited: userEdited ?? this.userEdited,
  );
}

class ReviewController extends Notifier<ReviewState> {
  String? _confirmationId;
  NutritionAnalysis? _activeAnalysis;

  @override
  ReviewState build() {
    final photo = ref.watch(photoControllerProvider);
    if (photo.phase == PhotoPhase.readyForReview && photo.analysis != null) {
      return _startReview(
        description: null,
        occurredAt: photo.occurredAt,
        analysis: photo.analysis!,
      );
    }
    final description = ref.watch(descriptionControllerProvider);
    if (description.phase != DescriptionPhase.readyForReview ||
        description.analysis == null) {
      _activeAnalysis = null;
      _confirmationId = null;
      return const ReviewState(phase: ReviewPhase.unavailable);
    }
    return _startReview(
      description: description.description.trim(),
      occurredAt: description.occurredAt,
      analysis: description.analysis!,
    );
  }

  ReviewState _startReview({
    required String? description,
    required DateTime occurredAt,
    required NutritionAnalysis analysis,
  }) {
    if (!identical(_activeAnalysis, analysis)) {
      _activeAnalysis = analysis;
      _confirmationId = null;
    }
    return ReviewState(
      phase: ReviewPhase.reviewing,
      description: description,
      occurredAt: occurredAt,
      analysis: analysis,
      items: List.unmodifiable(analysis.items),
    );
  }

  void updateOccurrence(DateTime occurredAt) {
    if (state.phase != ReviewPhase.reviewing) return;
    state = state.copyWith(occurredAt: occurredAt, userEdited: true);
  }

  void replaceItem(MealItem item) {
    if (state.phase != ReviewPhase.reviewing) return;
    final index = state.items.indexWhere((current) => current.id == item.id);
    if (index < 0) return;
    final items = [...state.items]..[index] = item;
    state = state.copyWith(items: items, userEdited: true);
  }

  void removeItem(String id) {
    if (state.phase != ReviewPhase.reviewing || state.items.length == 1) return;
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
      userEdited: true,
    );
  }

  MealItem addItem() {
    final item = MealItem(
      id: ref.read(idGeneratorProvider).newId(),
      name: 'New item',
      nutrition: NutritionFacts(const {}),
      confidence: MealConfidence.low,
    );
    state = state.copyWith(items: [...state.items, item], userEdited: true);
    return item;
  }

  Future<void> save() async {
    if (!state.canSave || state.analysis == null || state.occurredAt == null) {
      return;
    }
    final analysis = state.analysis!;
    _confirmationId ??= ref.read(idGeneratorProvider).newId();
    state = state.copyWith(phase: ReviewPhase.saving);
    try {
      await ref
          .read(mealRepositoryProvider)
          .create(
            MealEntryDraft(
              confirmationId: _confirmationId,
              occurredAtUtc: state.occurredAt!.toUtc(),
              occurredOffsetMinutes: state.occurredAt!.timeZoneOffset.inMinutes,
              description: state.description,
              items: state.items,
              provenance: analysis.provenance,
              confidence: analysis.confidence,
              assumptions: analysis.assumptions,
              userEdited: state.userEdited,
            ),
          );
      state = state.copyWith(phase: ReviewPhase.saved);
      _confirmationId = null;
      _activeAnalysis = null;
    } catch (_) {
      state = state.copyWith(phase: ReviewPhase.saveFailure);
    }
  }

  void retrySave() {
    if (state.phase != ReviewPhase.saveFailure) return;
    state = state.copyWith(phase: ReviewPhase.reviewing);
    unawaited(save());
  }
}

final reviewControllerProvider =
    NotifierProvider<ReviewController, ReviewState>(ReviewController.new);

class ItemEditState {
  const ItemEditState({required this.item, this.error});

  final MealItem item;
  final String? error;
}

/// A short-lived controller owned by the item-edit route. It has no provider or
/// persistence dependency; it commits a complete immutable item back to review.
class ItemEditController {
  ItemEditController(this.state, this._reviewController);

  ItemEditState state;
  final ReviewController _reviewController;

  bool save({
    required String name,
    required Map<NutrientId, NutritionValue> nutrition,
  }) {
    if (name.trim().isEmpty) {
      state = ItemEditState(item: state.item, error: 'nameRequired');
      return false;
    }
    final item = MealItem(
      id: state.item.id,
      name: name.trim(),
      amountDescription: state.item.amountDescription,
      normalizedGramsMilli: state.item.normalizedGramsMilli,
      confidence: state.item.confidence,
      assumptions: state.item.assumptions,
      nutrition: NutritionFacts(nutrition),
    );
    _reviewController.replaceItem(item);
    state = ItemEditState(item: item);
    return true;
  }
}
