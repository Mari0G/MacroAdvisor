import 'package:macro_advisor/src/features/settings/domain/credential_store.dart';

class InMemoryCredentialStore implements CredentialStore {
  final Map<String, String> _credentials = {};

  @override
  Future<void> delete(String providerId) async {
    _credentials.remove(providerId);
  }

  @override
  Future<String?> read(String providerId) async => _credentials[providerId];

  @override
  Future<void> write({
    required String providerId,
    required String credential,
  }) async {
    _credentials[providerId] = credential;
  }
}
