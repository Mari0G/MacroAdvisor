import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';
import 'package:macro_advisor/src/features/settings/application/meal_image_retention_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _changingRetention = false;
  Object? _retentionError;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final retention = ref.watch(mealImageRetentionEnabledProvider);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Card(
                  child: ListTile(
                    title: Text(localizations.goalsSectionTitle),
                    subtitle: Text(localizations.goalsSectionBody),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.goals),
                  ),
                ),
                _RetentionSettingsCard(
                  state: retention,
                  changing: _changingRetention,
                  error: _retentionError,
                  onChanged: _changeRetention,
                  onRetry: () => _retryRetention(retention),
                ),
                Card(
                  child: ListTile(
                    key: const Key('provider-settings-entry'),
                    title: Text(localizations.providerSettingsSectionTitle),
                    subtitle: Text(localizations.providerSettingsSectionBody),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.providerSettings),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      localizations.settingsPlaceholder,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeRetention(bool enabled) async {
    if (_changingRetention) return;
    final l10n = AppLocalizations.of(context);
    if (!enabled) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.disableSavedMealImagesTitle),
          content: Text(l10n.disableSavedMealImagesBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.disableSavedMealImagesAction),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await _saveRetention(enabled);
  }

  Future<void> _retryRetention(AsyncValue<bool> retention) async {
    final enabled = retention is AsyncData<bool> ? retention.value : null;
    if (enabled != null) {
      await _saveRetention(enabled);
    } else {
      ref.invalidate(mealImageRetentionEnabledProvider);
    }
  }

  Future<void> _saveRetention(bool enabled) async {
    setState(() {
      _changingRetention = true;
      _retentionError = null;
    });
    try {
      await ref.read(mealImageRetentionSettingsProvider).setEnabled(enabled);
      if (!mounted) return;
      ref.invalidate(mealImageRetentionEnabledProvider);
      setState(() => _changingRetention = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _changingRetention = false;
        _retentionError = Object();
      });
    }
  }
}

class _RetentionSettingsCard extends StatelessWidget {
  const _RetentionSettingsCard({
    required this.state,
    required this.changing,
    required this.error,
    required this.onChanged,
    required this.onRetry,
  });

  final AsyncValue<bool> state;
  final bool changing;
  final Object? error;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: state.when(
        loading: () => ListTile(
          title: Text(l10n.savedMealImagesTitle),
          subtitle: Text(l10n.savedMealImagesLoading),
          trailing: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, _) => ListTile(
          title: Text(l10n.savedMealImagesTitle),
          subtitle: Text(l10n.savedMealImagesLoadFailed),
          trailing: TextButton(
            onPressed: onRetry,
            child: Text(l10n.retryAction),
          ),
        ),
        data: (enabled) => Column(
          children: [
            SwitchListTile.adaptive(
              key: const Key('retention-setting-switch'),
              title: Text(l10n.savedMealImagesTitle),
              subtitle: Text(
                enabled
                    ? l10n.savedMealImagesEnabledBody
                    : l10n.savedMealImagesDisabledBody,
              ),
              value: enabled,
              onChanged: changing ? null : onChanged,
            ),
            if (error != null)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(child: Text(l10n.savedMealImagesSaveFailed)),
                      TextButton(
                        onPressed: changing ? null : onRetry,
                        child: Text(l10n.retryAction),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
