import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and German ARB files define the same message keys', () {
    Set<String> messageKeys(String path) {
      final values =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      return values.keys.where((key) => !key.startsWith('@')).toSet();
    }

    final english = messageKeys('lib/l10n/app_en.arb');
    final german = messageKeys('lib/l10n/app_de.arb');

    expect(german, equals(english));
  });
}
