import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/gemini_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_repository.dart';
import 'package:macro_advisor/src/features/settings/application/provider_settings_controller.dart';
import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/secure_credential_store.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final idGeneratorProvider = Provider<IdGenerator>((ref) => RandomIdGenerator());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final appMealRepositoryProvider = Provider<DriftMealRepository>((ref) {
  return DriftMealRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  );
});

/// Production bindings for secure provider configuration.
final appCredentialStoreProvider = Provider<SecureCredentialStore>((ref) {
  return SecureCredentialStore(const FlutterSecureStorage());
});

final appGeminiProvider = Provider<GeminiNutritionAnalysisProvider>((ref) {
  final provider = GeminiNutritionAnalysisProvider(
    credentialStore: ref.watch(appCredentialStoreProvider),
    clock: ref.watch(clockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
  ref.onDispose(provider.close);
  return provider;
});

final appConnectionCheckerProvider = Provider<ProviderConnectionChecker>(
  (ref) => ref.watch(appGeminiProvider),
);

final appNutritionAnalysisProvider = Provider<NutritionAnalysisProvider>(
  (ref) => ref.watch(appGeminiProvider),
);

List<Object?> productionOverrides() => [
  mealRepositoryProvider.overrideWith(
    (ref) => ref.watch(appMealRepositoryProvider),
  ),
  credentialStoreProvider.overrideWith(
    (ref) => ref.watch(appCredentialStoreProvider),
  ),
  providerConnectionCheckerProvider.overrideWith(
    (ref) => ref.watch(appConnectionCheckerProvider),
  ),
  nutritionAnalysisProvider.overrideWith(
    (ref) => ref.watch(appNutritionAnalysisProvider),
  ),
];
