import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';

void main() {
  final clock = _FixedClock(DateTime(2025, 1, 2, 9));

  Widget buildApp(Locale locale) => ProviderScope(
    overrides: [clockProvider.overrideWithValue(clock)],
    child: MacroAdvisorApp(locale: locale),
  );

  testWidgets('shows the localized English empty Today shell', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('en')));

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('No meals or drinks recorded'), findsOneWidget);
    expect(find.text('Meals and drinks (0)'), findsOneWidget);
    expect(find.text('Record meal'), findsNWidgets(2));
    expect(find.byTooltip('Open settings'), findsOneWidget);
  });

  testWidgets('shows the localized German empty Today shell', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('de')));

    expect(find.text('Heute'), findsOneWidget);
    expect(
      find.text('Noch keine Mahlzeiten oder Getränke erfasst'),
      findsOneWidget,
    );
    expect(find.text('Mahlzeiten und Getränke (0)'), findsOneWidget);
    expect(find.text('Mahlzeit erfassen'), findsNWidgets(2));
    expect(find.byTooltip('Einstellungen öffnen'), findsOneWidget);
  });

  testWidgets('opens the Settings placeholder from Today', (tester) async {
    await tester.pumpWidget(buildApp(const Locale('en')));

    await tester.tap(find.byTooltip('Open settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(
      find.text('Provider, goals, and language settings will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('uses a compact layout below the expanded breakpoint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(const Locale('en')));

    expect(find.byKey(const Key('today-compact-layout')), findsOneWidget);
    expect(find.byKey(const Key('today-expanded-layout')), findsNothing);
  });

  testWidgets('uses an expanded layout at wide widths', (tester) async {
    tester.view.physicalSize = const Size(1000, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(const Locale('en')));

    expect(find.byKey(const Key('today-expanded-layout')), findsOneWidget);
    expect(find.byKey(const Key('today-compact-layout')), findsNothing);
  });

  testWidgets('remains usable with German text at 200 percent scale', (
    tester,
  ) async {
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );

    await tester.pumpWidget(buildApp(const Locale('de')));

    expect(tester.takeException(), isNull);
    expect(find.text('Mahlzeit erfassen'), findsNWidgets(2));
  });
}

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
