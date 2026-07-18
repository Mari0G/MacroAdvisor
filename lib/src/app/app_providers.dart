import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/meal_capture/application/nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/deterministic_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/infrastructure/drift_meal_repository.dart';
import 'package:macro_advisor/src/features/settings/application/provider_settings_controller.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/deterministic_connection_checker.dart';
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

final appConnectionCheckerProvider = Provider<DeterministicConnectionChecker>((
  ref,
) {
  return const DeterministicConnectionChecker();
});

final appNutritionAnalysisProvider =
    Provider<DeterministicNutritionAnalysisProvider>((ref) {
      return DeterministicNutritionAnalysisProvider(
        ref.watch(clockProvider),
        ref.watch(idGeneratorProvider),
      );
    });

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
