import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/l10n/generated/app_localizations.dart';
import 'package:macro_advisor/src/features/settings/application/provider_settings_controller.dart';
import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/deterministic_connection_checker.dart';
import 'package:macro_advisor/src/features/settings/presentation/provider_settings_page.dart';
import '../../../../support/in_memory_credential_store.dart';

void main() {
  Widget buildPage(Locale locale, InMemoryCredentialStore store) {
    return ProviderScope(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        providerConnectionCheckerProvider.overrideWithValue(
          const DeterministicConnectionChecker(
            resultsByCredential: {
              'bad-key': ProviderConnectionResult.invalidCredential,
            },
          ),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProviderSettingsPage(),
      ),
    );
  }

  testWidgets('saves an English credential without leaving it visible', (
    tester,
  ) async {
    final store = InMemoryCredentialStore();
    await tester.pumpWidget(buildPage(const Locale('en'), store));
    await tester.pump();

    expect(find.text('No credential saved'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('provider-credential-field')),
      'private-key',
    );
    await tester.tap(find.byKey(const Key('save-credential-button')));
    await tester.pump();

    expect(await store.read(geminiProviderId), 'private-key');
    expect(find.text('Credential saved securely'), findsOneWidget);
    expect(find.text('private-key'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('provider-credential-field')),
          )
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('shows localized recovery for an invalid credential in German', (
    tester,
  ) async {
    final store = InMemoryCredentialStore();
    await tester.pumpWidget(buildPage(const Locale('de'), store));
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('provider-credential-field')),
      'bad-key',
    );
    await tester.tap(find.byKey(const Key('save-credential-button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('test-connection-button')));
    await tester.pump();

    expect(
      find.text(
        'Die Zugangsdaten fehlen oder sind ungültig. Ersetze sie und versuche es erneut.',
      ),
      findsOneWidget,
    );
    expect(find.text('bad-key'), findsNothing);
  });

  testWidgets('requires confirmation before removing a credential', (
    tester,
  ) async {
    final store = InMemoryCredentialStore();
    await store.write(providerId: geminiProviderId, credential: 'private-key');
    await tester.pumpWidget(buildPage(const Locale('en'), store));
    await tester.pump();

    await tester.tap(find.byKey(const Key('remove-credential-button')));
    await tester.pumpAndSettle();
    expect(find.text('Remove provider credential?'), findsOneWidget);
    expect(await store.read(geminiProviderId), 'private-key');

    await tester.tap(find.text('Remove credential').last);
    await tester.pumpAndSettle();
    expect(await store.read(geminiProviderId), isNull);
    expect(find.text('No credential saved'), findsOneWidget);
  });
}
