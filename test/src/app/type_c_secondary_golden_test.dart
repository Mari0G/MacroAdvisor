import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/app_theme.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/features/dashboard/domain/local_day.dart';
import 'package:macro_advisor/src/features/goals/domain/goal.dart';
import 'package:macro_advisor/src/features/history/domain/history.dart';
import 'package:macro_advisor/src/features/history/presentation/history_page.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/deterministic_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/describe_meal_page.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/review_estimate_page.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/meals/presentation/meal_detail_page.dart';
import 'package:macro_advisor/src/features/settings/domain/app_palette.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('History Lime baseline', (tester) async {
    _compact(tester);
    final selection = HistorySelection.initial(LocalDay(2026, 7, 20));
    final model = HistoryDisplayModel.fromEntries(
      selection: selection,
      entries: [_entry()],
      goals: GoalSet.empty(),
    );
    await tester.pumpWidget(
      _shell(
        HistoryView(
          selection: selection,
          history: AsyncData(model),
          onNutrientChanged: (_) {},
          onPeriodChanged: (_) {},
          onAnchorChanged: (_) {},
          onCustomRangeChanged: (_, _) {},
          onRetry: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(HistoryView),
      matchesGoldenFile('goldens/history_lime.png'),
    );
  });

  testWidgets('Describe Lime baseline', (tester) async {
    _compact(tester);
    final container = _container();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      _shell(const DescribeMealPage(), container: container),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(DescribeMealPage),
      matchesGoldenFile('goldens/describe_lime.png'),
    );
  });

  testWidgets('Review Lime baseline', (tester) async {
    _compact(tester);
    final container = _container();
    addTearDown(container.dispose);
    final controller = container.read(descriptionControllerProvider.notifier);
    controller.updateDescription('Synthetic oats and fruit');
    await controller.analyze('en');
    await tester.pumpWidget(
      _shell(const ReviewEstimatePage(), container: container),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ReviewEstimatePage),
      matchesGoldenFile('goldens/review_lime.png'),
    );
  });

  testWidgets('Meal detail Lime baseline', (tester) async {
    _compact(tester);
    final container = _container(
      extra: [
        mealRepositoryProvider.overrideWithValue(
          _StaticMealRepository(_entry()),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      _shell(
        const MealDetailPage(mealId: 'synthetic-meal'),
        container: container,
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MealDetailPage),
      matchesGoldenFile('goldens/meal_detail_lime.png'),
    );
  });
}

void _compact(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

ProviderContainer _container({List<Object?> extra = const []}) {
  const clock = _FixedClock();
  const ids = _FixedIds();
  return ProviderContainer(
    overrides: [
      clockProvider.overrideWithValue(clock),
      idGeneratorProvider.overrideWithValue(ids),
      nutritionAnalysisProvider.overrideWithValue(
        DeterministicNutritionAnalysisProvider(clock, ids),
      ),
      ...extra,
    ].cast(),
  );
}

Widget _shell(Widget home, {ProviderContainer? container}) {
  final theme = AppTheme.forPalette(AppPalette.lime);
  final app = MaterialApp(
    locale: const Locale('en'),
    theme: theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamily: 'Ahem'),
      primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Ahem'),
      appBarTheme: theme.appBarTheme.copyWith(
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Ahem',
        ),
      ),
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
  return container == null
      ? ProviderScope(child: app)
      : UncontrolledProviderScope(container: container, child: app);
}

class _FixedClock implements Clock {
  const _FixedClock();
  @override
  DateTime now() => DateTime(2026, 7, 20, 12);
}

class _FixedIds implements IdGenerator {
  const _FixedIds();
  @override
  String newId() => 'synthetic-id';
}

class _StaticMealRepository implements MealRepository {
  const _StaticMealRepository(this.entry);
  final MealEntry entry;
  @override
  Future<MealEntry?> findById(String id, {bool includeDeleted = false}) async =>
      entry;
  @override
  Stream<List<MealEntry>> observeDay(DateTime localDay) =>
      Stream.value([entry]);
  @override
  Stream<List<MealEntry>> observeRange(DateTime start, DateTime end) =>
      Stream.value([entry]);
  @override
  Future<MealEntry> create(MealEntryDraft draft) => throw UnimplementedError();
  @override
  Future<MealEntry> update(MealEntry entry) => throw UnimplementedError();
  @override
  Future<MealEntry> softDelete({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();
  @override
  Future<MealEntry> restore({
    required String id,
    required int expectedRevision,
  }) => throw UnimplementedError();
}

MealEntry _entry() => MealEntry(
  id: 'synthetic-meal',
  createdAtUtc: DateTime.utc(2026, 7, 20, 10),
  updatedAtUtc: DateTime.utc(2026, 7, 20, 10),
  revision: 1,
  occurredAtUtc: DateTime.utc(2026, 7, 20, 10),
  occurredOffsetMinutes: 120,
  description: 'Synthetic oats and fruit',
  items: [
    MealItem(
      id: 'synthetic-item',
      name: 'Oats and fruit',
      nutrition: NutritionFacts({
        NutrientId.energy: const KnownNutritionValue(
          milliUnits: 450000,
          unit: NutritionUnit.kilocalories,
          source: NutritionValueSource.providerEstimate,
        ),
        NutrientId.protein: const KnownNutritionValue(
          milliUnits: 20000,
          unit: NutritionUnit.grams,
          source: NutritionValueSource.providerEstimate,
        ),
      }),
      confidence: MealConfidence.medium,
    ),
  ],
  provenance: MealProvenance(
    providerId: 'fixture',
    modelId: 'synthetic',
    analyzedAtUtc: DateTime.utc(2026, 7, 20, 10),
    detectedLocale: 'en',
  ),
);
