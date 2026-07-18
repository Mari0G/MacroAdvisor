import 'package:flutter/material.dart';
import 'package:macro_advisor/src/features/dashboard/presentation/today_page.dart';
import 'package:macro_advisor/src/features/settings/presentation/provider_settings_page.dart';
import 'package:macro_advisor/src/features/settings/presentation/settings_page.dart';

abstract final class AppRoutes {
  static const today = '/';
  static const settings = '/settings';
  static const providerSettings = '/settings/provider';
}

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutes.settings => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const SettingsPage(),
      ),
      AppRoutes.providerSettings => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ProviderSettingsPage(),
      ),
      _ => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const TodayPage(),
      ),
    };
  }
}
