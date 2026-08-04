import 'package:flutter/material.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/core/presentation/responsive_content.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
}
