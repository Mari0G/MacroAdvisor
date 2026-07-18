import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/settings/domain/credential_store.dart';
import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/deterministic_connection_checker.dart';
import '../../../../support/in_memory_credential_store.dart';

void main() {
  group('CredentialStore contract', () {
    late CredentialStore store;

    setUp(() {
      store = InMemoryCredentialStore();
    });

    test('writes, replaces, and removes a provider credential', () async {
      expect(await store.read('gemini'), isNull);

      await store.write(providerId: 'gemini', credential: 'first-secret');
      expect(await store.read('gemini'), 'first-secret');

      await store.write(providerId: 'gemini', credential: 'replacement-secret');
      expect(await store.read('gemini'), 'replacement-secret');

      await store.delete('gemini');
      expect(await store.read('gemini'), isNull);
    });
  });

  test(
    'deterministic connection checker returns configured outcomes',
    () async {
      const checker = DeterministicConnectionChecker(
        resultsByCredential: {
          'invalid': ProviderConnectionResult.invalidCredential,
          'offline': ProviderConnectionResult.offline,
        },
      );

      expect(await checker.check('ordinary'), ProviderConnectionResult.success);
      expect(
        await checker.check('invalid'),
        ProviderConnectionResult.invalidCredential,
      );
      expect(await checker.check('offline'), ProviderConnectionResult.offline);
    },
  );
}
