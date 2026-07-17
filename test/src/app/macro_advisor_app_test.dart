import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';

void main() {
  Widget buildApp(Locale locale) {
    return ProviderScope(child: MacroAdvisorApp(locale: locale));
  }

  testWidgets('shows the English setup example', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('en')));

    expect(find.text('Your local nutrition overview'), findsOneWidget);
    expect(
      find.text('The project setup is ready. Product features follow next.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the German setup example', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('de')));

    expect(find.text('Dein lokaler Ernährungsüberblick'), findsOneWidget);
    expect(
      find.text(
        'Das Projekt-Setup steht. Die Produktfunktionen folgen als Nächstes.',
      ),
      findsOneWidget,
    );
  });
}
