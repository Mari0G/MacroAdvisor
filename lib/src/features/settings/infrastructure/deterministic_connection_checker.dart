import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';

/// Predictable development and test substitute until a real provider adapter
/// exists. It deliberately has no network or logging behavior.
class DeterministicConnectionChecker implements ProviderConnectionChecker {
  const DeterministicConnectionChecker({
    this.defaultResult = ProviderConnectionResult.success,
    this.resultsByCredential = const {},
  });

  final ProviderConnectionResult defaultResult;
  final Map<String, ProviderConnectionResult> resultsByCredential;

  @override
  Future<ProviderConnectionResult> check(String credential) async {
    return resultsByCredential[credential] ?? defaultResult;
  }
}
