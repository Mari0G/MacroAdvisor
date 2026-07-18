import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:macro_advisor/src/features/settings/domain/credential_store.dart';

/// Secure-storage implementation of [CredentialStore].
class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore(this._storage);

  static const _keyPrefix = 'provider-credential.';

  final FlutterSecureStorage _storage;

  @override
  Future<void> delete(String providerId) =>
      _storage.delete(key: _storageKey(providerId));

  @override
  Future<String?> read(String providerId) =>
      _storage.read(key: _storageKey(providerId));

  @override
  Future<void> write({
    required String providerId,
    required String credential,
  }) => _storage.write(key: _storageKey(providerId), value: credential);

  String _storageKey(String providerId) => '$_keyPrefix$providerId';
}
