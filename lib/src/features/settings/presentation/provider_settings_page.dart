import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/settings/application/provider_settings_controller.dart';
import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';

class ProviderSettingsPage extends ConsumerStatefulWidget {
  const ProviderSettingsPage({super.key});

  @override
  ConsumerState<ProviderSettingsPage> createState() =>
      _ProviderSettingsPageState();
}

class _ProviderSettingsPageState extends ConsumerState<ProviderSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _credentialController = TextEditingController();
  bool _obscureCredential = true;

  @override
  void dispose() {
    _credentialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = ref.watch(providerSettingsControllerProvider);
    final controller = ref.read(providerSettingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.providerSettingsTitle)),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              Text(
                localizations.providerSettingsProviderName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(_configurationText(localizations, state.configuration)),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: TextFormField(
                  key: const Key('provider-credential-field'),
                  controller: _credentialController,
                  enabled: !state.isBusy,
                  obscureText: _obscureCredential,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: localizations.providerCredentialLabel,
                    helperText: localizations.providerCredentialHelper,
                    suffixIcon: IconButton(
                      tooltip: _obscureCredential
                          ? localizations.showCredentialTooltip
                          : localizations.hideCredentialTooltip,
                      onPressed: state.isBusy
                          ? null
                          : () => setState(
                              () => _obscureCredential = !_obscureCredential,
                            ),
                      icon: Icon(
                        _obscureCredential
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? localizations.providerCredentialRequired
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('save-credential-button'),
                onPressed: state.isBusy
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        await controller.saveCredential(
                          _credentialController.text,
                        );
                        if (mounted) {
                          _credentialController.clear();
                        }
                      },
                child: _operationLabel(
                  state.operation,
                  ProviderSettingsOperation.saving,
                  localizations.saveCredentialAction,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('test-connection-button'),
                onPressed: state.isBusy ? null : controller.testConnection,
                child: _operationLabel(
                  state.operation,
                  ProviderSettingsOperation.testing,
                  localizations.testConnectionAction,
                ),
              ),
              if (state.configuration ==
                  CredentialConfiguration.configured) ...[
                const SizedBox(height: 12),
                TextButton(
                  key: const Key('remove-credential-button'),
                  onPressed: state.isBusy
                      ? null
                      : () => _confirmRemoval(context, controller),
                  child: Text(localizations.removeCredentialAction),
                ),
              ],
              if (state.connectionResult != null) ...[
                const SizedBox(height: 24),
                _ConnectionResultCard(result: state.connectionResult!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _configurationText(
    AppLocalizations localizations,
    CredentialConfiguration configuration,
  ) {
    return switch (configuration) {
      CredentialConfiguration.checking =>
        localizations.credentialStatusChecking,
      CredentialConfiguration.missing => localizations.credentialStatusMissing,
      CredentialConfiguration.configured =>
        localizations.credentialStatusConfigured,
    };
  }

  Widget _operationLabel(
    ProviderSettingsOperation activeOperation,
    ProviderSettingsOperation expectedOperation,
    String idleLabel,
  ) {
    return activeOperation == expectedOperation
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          )
        : Text(idleLabel);
  }

  Future<void> _confirmRemoval(
    BuildContext context,
    ProviderSettingsController controller,
  ) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.removeCredentialTitle),
        content: Text(localizations.removeCredentialBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.removeCredentialAction),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.removeCredential();
    }
  }
}

class _ConnectionResultCard extends StatelessWidget {
  const _ConnectionResultCard({required this.result});

  final ProviderConnectionResult result;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final message = switch (result) {
      ProviderConnectionResult.success => localizations.connectionSuccess,
      ProviderConnectionResult.invalidCredential =>
        localizations.connectionInvalidCredential,
      ProviderConnectionResult.offline => localizations.connectionOffline,
      ProviderConnectionResult.rateLimited =>
        localizations.connectionRateLimited,
      ProviderConnectionResult.unavailable =>
        localizations.connectionUnavailable,
    };
    return Semantics(
      liveRegion: true,
      child: Card(
        child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
      ),
    );
  }
}
