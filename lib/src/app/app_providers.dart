import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/features/settings/application/provider_settings_controller.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/deterministic_connection_checker.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/secure_credential_store.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final idGeneratorProvider = Provider<IdGenerator>((ref) => RandomIdGenerator());

/// Production bindings for secure provider configuration.
final appCredentialStoreProvider = Provider<SecureCredentialStore>((ref) {
  return SecureCredentialStore(const FlutterSecureStorage());
});

final appConnectionCheckerProvider = Provider<DeterministicConnectionChecker>((
  ref,
) {
  return const DeterministicConnectionChecker();
});

List<Object?> productionOverrides() => [
  credentialStoreProvider.overrideWith(
    (ref) => ref.watch(appCredentialStoreProvider),
  ),
  providerConnectionCheckerProvider.overrideWith(
    (ref) => ref.watch(appConnectionCheckerProvider),
  ),
];
