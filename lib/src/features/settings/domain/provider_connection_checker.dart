/// Provider-neutral outcome of testing a stored provider credential.
enum ProviderConnectionResult {
  success,
  invalidCredential,
  offline,
  rateLimited,
  unavailable,
}

/// Tests a credential without exposing provider SDK details to the UI.
abstract interface class ProviderConnectionChecker {
  Future<ProviderConnectionResult> check(String credential);
}
