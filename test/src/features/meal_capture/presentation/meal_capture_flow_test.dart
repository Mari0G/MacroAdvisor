import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/features/goals/application/goal_repository_provider.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/goals/domain/goal_repository.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/deterministic_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

void main() {
  testWidgets('back cannot discard while confirmation awaits candidate', (
    tester,
  ) async {
    final repository = _Repository();
    final deriver = _CandidateDeriver();
    await tester.pumpWidget(
      _app(
        const Locale('en'),
        repository,
        source: _PhotoSource(acquirePhoto: true),
        deriver: deriver,
      ),
    );
    await tester.tap(find.text('Record meal').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('choose-photo-source')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('analyze-photo-button')),
      300,
    );
    await tester.tap(find.byKey(const Key('analyze-photo-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-save-button')));
    await tester.pump();
    await tester.pageBack();
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Review estimate'), findsOneWidget);
    deriver.complete();
    await tester.pumpAndSettle();
    expect(repository.created, hasLength(1));
    expect(find.text('Today').first, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final pending in [false, true]) {
    testWidgets('discard review releases candidate (pending: $pending)', (
      tester,
    ) async {
      final repository = _Repository();
      final deriver = _CandidateDeriver();
      if (!pending) deriver.complete();
      await tester.pumpWidget(
        _app(
          const Locale('en'),
          repository,
          source: _PhotoSource(acquirePhoto: true),
          deriver: deriver,
        ),
      );
      await tester.tap(find.text('Record meal').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('choose-photo-source')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('analyze-photo-button')),
        300,
      );
      await tester.tap(find.byKey(const Key('analyze-photo-button')));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.text('Review estimate')),
      );
      final controller = container.read(photoControllerProvider.notifier);
      final before = controller.readRetentionCandidate();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      expect(identical(before, controller.readRetentionCandidate()), isTrue);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard').last);
      await tester.pumpAndSettle();
      if (pending) deriver.complete();
      await tester.pumpAndSettle();
      expect(await controller.readRetentionCandidate(), isNull);
      expect(container.read(photoControllerProvider).photo, isNull);
      expect(repository.created, isEmpty);
      expect(find.text('Today').first, findsOneWidget);
    });
  }
  testWidgets('English user can review, edit, and save a text estimate', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(_app(const Locale('en'), repository));

    await tester.tap(find.text('Record meal').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('describe-meal-source')));
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
    expect(find.text('Today').first, findsOneWidget);
  });

  testWidgets('English provider timeout keeps input and offers retry', (
    tester,
  ) async {
    final provider = _TimeoutThenSuccessProvider();
    await tester.pumpWidget(
      _app(const Locale('en'), _Repository(), provider: provider),
    );

    await tester.tap(find.text('Record meal').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('describe-meal-source')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('meal-description-field')),
      'Tomato soup',
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('analyze-meal-button')));
    await tester.tap(find.byKey(const Key('analyze-meal-button')));
    await tester.pumpAndSettle();
    expect(provider.calls, 1);

    expect(
      find.text('The provider took too long to respond. Try again.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'No connection is available. Check your network and try again.',
      ),
      findsNothing,
    );
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('meal-description-field')))
          .controller
          ?.text,
      'Tomato soup',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Review estimate'), findsOneWidget);
  });

  testWidgets('German provider timeout uses localized recovery copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Locale('de'),
        _Repository(),
        provider: _TimeoutThenSuccessProvider(),
      ),
    );

    await tester.tap(find.text('Mahlzeit erfassen').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('describe-meal-source')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('meal-description-field')),
      'Tomatensuppe',
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('analyze-meal-button')));
    await tester.tap(find.byKey(const Key('analyze-meal-button')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Der Anbieter hat zu lange für eine Antwort gebraucht. Versuche es erneut.',
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FilledButton, 'Erneut versuchen'),
      findsOneWidget,
    );
  });

  testWidgets(
    'German description form is localized and whitespace cannot submit',
    (tester) async {
      await tester.pumpWidget(_app(const Locale('de'), _Repository()));
      await tester.tap(find.text('Mahlzeit erfassen').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('describe-meal-source')));
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

  testWidgets('photo preview explains provider transmission before analysis', (
    tester,
  ) async {
    final repository = _Repository();
    final source = _PhotoSource(acquirePhoto: true);
    await tester.pumpWidget(
      _app(const Locale('en'), repository, source: source),
    );

    await tester.tap(find.text('Record meal').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('choose-photo-source')));
    await tester.pumpAndSettle();

    expect(find.text('Photo meal or drink'), findsOneWidget);
    expect(
      find.textContaining('sent to your configured AI provider'),
      findsOneWidget,
    );
    expect(
      find.textContaining('not attached to the saved meal'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('analyze-photo-button')),
      300,
    );
    await tester.tap(find.byKey(const Key('analyze-photo-button')));
    await tester.pumpAndSettle();
    expect(find.text('Review estimate'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-save-button')));
    await tester.pumpAndSettle();

    expect(repository.created.single.description, isNull);
  });
}

Widget _app(
  Locale locale,
  _Repository repository, {
  _PhotoSource? source,
  NutritionAnalysisProvider? provider,
  MealPhotoRetentionCandidateDeriver? deriver,
}) {
  final clock = _Clock(DateTime(2026, 7, 18, 12));
  final ids = _Ids();
  return ProviderScope(
    overrides: [
      clockProvider.overrideWithValue(clock),
      idGeneratorProvider.overrideWithValue(ids),
      mealRepositoryProvider.overrideWithValue(repository),
      goalRepositoryProvider.overrideWithValue(_EmptyGoalRepository()),
      nutritionAnalysisProvider.overrideWithValue(
        provider ?? DeterministicNutritionAnalysisProvider(clock, ids),
      ),
      mealPhotoSourceProvider.overrideWithValue(source ?? _PhotoSource()),
      mealPhotoNormalizerProvider.overrideWithValue(_PhotoNormalizer()),
      if (deriver != null)
        mealPhotoRetentionCandidateDeriverProvider.overrideWithValue(deriver),
    ],
    child: MacroAdvisorApp(locale: locale),
  );
}

class _TimeoutThenSuccessProvider implements NutritionAnalysisProvider {
  var _calls = 0;

  int get calls => _calls;

  @override
  Future<NutritionAnalysis> analyzeText(
    NutritionAnalysisRequest request,
  ) async {
    _calls++;
    if (_calls == 1) {
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
      items: [
        MealItem(
          id: 'timeout-item',
          name: 'Tomato soup',
          nutrition: NutritionFacts(const {}),
          confidence: MealConfidence.medium,
        ),
      ],
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
  _PhotoSource({this.acquirePhoto = false});

  final bool acquirePhoto;

  @override
  Future<MealPhotoAcquisition> acquire(MealPhotoSourceType source) async {
    if (!acquirePhoto) return const CancelledMealPhotoAcquisition();
    final picture = image.Image(width: 1, height: 1)
      ..clear(image.ColorRgb8(0, 0, 0));
    return AcquiredMealPhoto(Uint8List.fromList(image.encodeJpg(picture)));
  }

  @override
  Future<MealPhotoAcquisition?> recoverLostData() async => null;
}

class _PhotoNormalizer implements MealPhotoNormalizer {
  @override
  Future<MealPhoto> normalize(Uint8List sourceBytes) async =>
      MealPhoto(jpegBytes: sourceBytes, width: 1, height: 1);
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

class _EmptyGoalRepository implements GoalRepository {
  @override
  Future<GoalSet> read() async => GoalSet.empty();

  @override
  Stream<GoalSet> observe() => Stream.value(GoalSet.empty());

  @override
  Future<GoalSet> replace(GoalSet goals) async => goals;
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

class _CandidateDeriver implements MealPhotoRetentionCandidateDeriver {
  final completer = Completer<MealPhotoRetentionCandidate>();
  void complete() {
    final picture = image.Image(width: 2, height: 2);
    completer.complete(
      MealPhotoRetentionCandidate(
        jpegBytes: Uint8List.fromList(image.encodeJpg(picture)),
        width: 2,
        height: 2,
      ),
    );
  }

  @override
  Future<MealPhotoRetentionCandidate> deriveRetentionCandidate(
    MealPhoto photo,
  ) => completer.future;
}
