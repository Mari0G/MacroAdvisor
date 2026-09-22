import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/app/app_theme.dart';
import 'package:macro_advisor/src/features/settings/domain/app_palette.dart';
import 'package:macro_advisor/src/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets('renders Lime Settings with palette choices', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final theme = AppTheme.forPalette(AppPalette.lime);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          theme: theme.copyWith(
            textTheme: theme.textTheme.apply(fontFamily: 'Ahem'),
            appBarTheme: theme.appBarTheme.copyWith(
              titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
                fontFamily: 'Ahem',
              ),
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/settings_lime.png'),
    );
  });
}
