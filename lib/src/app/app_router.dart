import 'package:flutter/material.dart';
import 'package:macro_advisor/src/features/dashboard/presentation/today_page.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/describe_meal_page.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/edit_item_page.dart';
import 'package:macro_advisor/src/features/meal_capture/presentation/review_estimate_page.dart';
import 'package:macro_advisor/src/features/settings/presentation/provider_settings_page.dart';
import 'package:macro_advisor/src/features/settings/presentation/settings_page.dart';

abstract final class AppRoutes {
  static const today = '/';
  static const settings = '/settings';
  static const providerSettings = '/settings/provider';
  static const describeMeal = '/capture/describe';
  static const reviewMeal = '/capture/review';
  static const editMealItem = '/capture/item';
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
      AppRoutes.describeMeal => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const DescribeMealPage(),
      ),
      AppRoutes.reviewMeal => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ReviewEstimatePage(),
      ),
      AppRoutes.editMealItem => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => EditItemPage(itemId: settings.arguments! as String),
      ),
      _ => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const TodayPage(),
      ),
    };
  }
}
