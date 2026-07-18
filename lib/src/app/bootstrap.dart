import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/app/app_providers.dart';
import 'package:macro_advisor/src/app/macro_advisor_app.dart';

/// Starts the app with the production composition root.
///
/// [overrides] is intentionally accepted at this boundary so integration tests
/// can replace platform dependencies without reaching into widgets.
void bootstrap({List<Object?> overrides = const []}) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [...productionOverrides(), ...overrides].cast(),
      child: const MacroAdvisorApp(),
    ),
  );
}
