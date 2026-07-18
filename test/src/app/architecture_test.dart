import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production source respects the initial layer import boundaries', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final normalized = file.path.replaceAll('\\', '/');
      final source = file.readAsStringSync();
      if (normalized.contains('/domain/')) {
        expect(
          source,
          isNot(contains('package:flutter/')),
          reason: '${file.path} is domain code and cannot import Flutter.',
        );
        expect(
          source,
          isNot(contains('package:drift/')),
          reason: '${file.path} is domain code and cannot import Drift.',
        );
      }
      if (normalized.contains('/presentation/')) {
        expect(
          source,
          isNot(contains('/infrastructure/')),
          reason:
              '${file.path} is presentation code and cannot import infrastructure.',
        );
      }
    }
  });
}
