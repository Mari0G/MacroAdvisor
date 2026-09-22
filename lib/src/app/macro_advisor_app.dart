import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_router.dart';
import 'package:macro_advisor/src/app/app_theme.dart';
import 'package:macro_advisor/src/features/meal_capture/application/capture_controllers.dart';
import 'package:macro_advisor/src/features/settings/application/appearance_controller.dart';

class MacroAdvisorApp extends ConsumerWidget {
  const MacroAdvisorApp({this.locale, super.key});

  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(appearanceControllerProvider).palette;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.forPalette(palette),
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.today,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) => _PhotoLostDataRecovery(child: child!),
    );
  }
}

class _PhotoLostDataRecovery extends ConsumerStatefulWidget {
  const _PhotoLostDataRecovery({required this.child});

  final Widget child;

  @override
  ConsumerState<_PhotoLostDataRecovery> createState() =>
      _PhotoLostDataRecoveryState();
}

class _PhotoLostDataRecoveryState
    extends ConsumerState<_PhotoLostDataRecovery> {
  var _attempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_attempted) return;
    _attempted = true;
    Future<void>.microtask(() async {
      await ref.read(photoControllerProvider.notifier).recoverLostPickerData();
      if (mounted && ref.read(photoControllerProvider).photo != null) {
        await Navigator.of(context).pushNamed(AppRoutes.photoMeal);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
