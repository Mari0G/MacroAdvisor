/// Stores provider credentials in a platform-backed secure store.
///
/// Implementations must never persist credentials in ordinary preferences or a
/// local database. Callers must also avoid putting returned values into UI
/// state, logs, route arguments, or error messages.
abstract interface class CredentialStore {
  Future<String?> read(String providerId);

  Future<void> write({required String providerId, required String credential});

  Future<void> delete(String providerId);
}
