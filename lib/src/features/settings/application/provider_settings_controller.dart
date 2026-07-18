import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/settings/domain/credential_store.dart';
import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';

const geminiProviderId = 'gemini';

enum CredentialConfiguration { checking, missing, configured }

enum ProviderSettingsOperation { idle, saving, testing, removing }

class ProviderSettingsState {
  const ProviderSettingsState({
    required this.configuration,
    this.operation = ProviderSettingsOperation.idle,
    this.connectionResult,
  });

  const ProviderSettingsState.checking()
    : configuration = CredentialConfiguration.checking,
      operation = ProviderSettingsOperation.idle,
      connectionResult = null;

  final CredentialConfiguration configuration;
  final ProviderSettingsOperation operation;
  final ProviderConnectionResult? connectionResult;

  bool get isBusy => operation != ProviderSettingsOperation.idle;

  ProviderSettingsState copyWith({
    CredentialConfiguration? configuration,
    ProviderSettingsOperation? operation,
    ProviderConnectionResult? connectionResult,
    bool clearConnectionResult = false,
  }) {
    return ProviderSettingsState(
      configuration: configuration ?? this.configuration,
      operation: operation ?? this.operation,
      connectionResult: clearConnectionResult
          ? null
          : connectionResult ?? this.connectionResult,
    );
  }
}

/// Manages credential status only. A credential is accepted transiently by a
/// command, then deliberately omitted from [ProviderSettingsState].
class ProviderSettingsController extends Notifier<ProviderSettingsState> {
  @override
  ProviderSettingsState build() {
    unawaited(_load());
    return const ProviderSettingsState.checking();
  }

  CredentialStore get _credentialStore => ref.read(credentialStoreProvider);
  ProviderConnectionChecker get _connectionChecker =>
      ref.read(providerConnectionCheckerProvider);

  Future<void> saveCredential(String credential) async {
    final normalizedCredential = credential.trim();
    if (normalizedCredential.isEmpty) {
      return;
    }

    state = state.copyWith(
      operation: ProviderSettingsOperation.saving,
      clearConnectionResult: true,
    );
    try {
      await _credentialStore.write(
        providerId: geminiProviderId,
        credential: normalizedCredential,
      );
      state = const ProviderSettingsState(
        configuration: CredentialConfiguration.configured,
      );
    } catch (_) {
      state = state.copyWith(operation: ProviderSettingsOperation.idle);
    }
  }

  Future<void> testConnection() async {
    state = state.copyWith(
      operation: ProviderSettingsOperation.testing,
      clearConnectionResult: true,
    );
    try {
      final credential = await _credentialStore.read(geminiProviderId);
      if (credential == null || credential.isEmpty) {
        state = const ProviderSettingsState(
          configuration: CredentialConfiguration.missing,
          connectionResult: ProviderConnectionResult.invalidCredential,
        );
        return;
      }
      final result = await _connectionChecker.check(credential);
      state = ProviderSettingsState(
        configuration: CredentialConfiguration.configured,
        connectionResult: result,
      );
    } catch (_) {
      state = const ProviderSettingsState(
        configuration: CredentialConfiguration.configured,
        connectionResult: ProviderConnectionResult.unavailable,
      );
    }
  }

  Future<void> removeCredential() async {
    state = state.copyWith(
      operation: ProviderSettingsOperation.removing,
      clearConnectionResult: true,
    );
    try {
      await _credentialStore.delete(geminiProviderId);
      state = const ProviderSettingsState(
        configuration: CredentialConfiguration.missing,
      );
    } catch (_) {
      state = state.copyWith(operation: ProviderSettingsOperation.idle);
    }
  }

  Future<void> _load() async {
    try {
      final credential = await _credentialStore.read(geminiProviderId);
      state = ProviderSettingsState(
        configuration: credential == null || credential.isEmpty
            ? CredentialConfiguration.missing
            : CredentialConfiguration.configured,
      );
    } catch (_) {
      state = const ProviderSettingsState(
        configuration: CredentialConfiguration.missing,
      );
    }
  }
}

final credentialStoreProvider = Provider<CredentialStore>((ref) {
  throw UnimplementedError('CredentialStore must be provided by the app.');
});

final providerConnectionCheckerProvider = Provider<ProviderConnectionChecker>((
  ref,
) {
  throw UnimplementedError(
    'ProviderConnectionChecker must be provided by the app.',
  );
});

final providerSettingsControllerProvider =
    NotifierProvider<ProviderSettingsController, ProviderSettingsState>(
      ProviderSettingsController.new,
    );
