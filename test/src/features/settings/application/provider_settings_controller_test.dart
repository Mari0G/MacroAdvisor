import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/settings/application/provider_settings_controller.dart';
import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/deterministic_connection_checker.dart';
import '../../../../support/in_memory_credential_store.dart';

void main() {
  late InMemoryCredentialStore store;
  late ProviderContainer container;

  setUp(() {
    store = InMemoryCredentialStore();
    container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        providerConnectionCheckerProvider.overrideWithValue(
          const DeterministicConnectionChecker(
            resultsByCredential: {
              'invalid-secret': ProviderConnectionResult.invalidCredential,
              'offline-secret': ProviderConnectionResult.offline,
              'limited-secret': ProviderConnectionResult.rateLimited,
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<ProviderSettingsController> readController() async {
    final controller = container.read(
      providerSettingsControllerProvider.notifier,
    );
    await Future<void>.delayed(Duration.zero);
    return controller;
  }

  test(
    'persists a trimmed credential without retaining it in display state',
    () async {
      final controller = await readController();

      await controller.saveCredential('  secret-value  ');

      expect(await store.read(geminiProviderId), 'secret-value');
      final state = container.read(providerSettingsControllerProvider);
      expect(state.configuration, CredentialConfiguration.configured);
      expect(state.toString(), isNot(contains('secret-value')));
      expect(state.runtimeType.toString(), isNot(contains('secret-value')));
    },
  );

  test(
    'maps configured connection outcomes without exposing the credential',
    () async {
      final controller = await readController();
      await controller.saveCredential('offline-secret');

      await controller.testConnection();

      final state = container.read(providerSettingsControllerProvider);
      expect(state.connectionResult, ProviderConnectionResult.offline);
      expect(state.toString(), isNot(contains('offline-secret')));
    },
  );

  test(
    'keeps provider-neutral success, invalid, and rate-limit outcomes',
    () async {
      final controller = await readController();

      await controller.saveCredential('ordinary-secret');
      await controller.testConnection();
      expect(
        container.read(providerSettingsControllerProvider).connectionResult,
        ProviderConnectionResult.success,
      );

      await controller.saveCredential('invalid-secret');
      await controller.testConnection();
      expect(
        container.read(providerSettingsControllerProvider).connectionResult,
        ProviderConnectionResult.invalidCredential,
      );

      await controller.saveCredential('limited-secret');
      await controller.testConnection();
      expect(
        container.read(providerSettingsControllerProvider).connectionResult,
        ProviderConnectionResult.rateLimited,
      );
    },
  );

  test(
    'reports missing credentials recoverably and removes saved credentials',
    () async {
      final controller = await readController();

      await controller.testConnection();
      expect(
        container.read(providerSettingsControllerProvider).connectionResult,
        ProviderConnectionResult.invalidCredential,
      );

      await controller.saveCredential('remove-me');
      await controller.removeCredential();
      expect(await store.read(geminiProviderId), isNull);
      expect(
        container.read(providerSettingsControllerProvider).configuration,
        CredentialConfiguration.missing,
      );
    },
  );
}
