import 'package:flutter/material.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
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
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  localizations.settingsPlaceholder,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
