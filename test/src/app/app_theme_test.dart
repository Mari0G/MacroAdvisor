import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/app/app_theme.dart';
import 'package:macro_advisor/src/features/settings/domain/app_palette.dart';

void main() {
  test('Type C color roles retain readable text and visible focus', () {
    for (final palette in AppPalette.values) {
      final theme = AppTheme.forPalette(palette);
      final tokens = theme.extension<TypeCTokens>()!;
      final scheme = theme.colorScheme;
      expect(theme.brightness, Brightness.dark);
      expect(
        _contrast(scheme.onSurface, tokens.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.onSurface, tokens.card),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(tokens.muted, tokens.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(_contrast(tokens.muted, tokens.card), greaterThanOrEqualTo(4.5));
      expect(
        _contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.primary, tokens.background),
        greaterThanOrEqualTo(3),
      );
      expect(_contrast(scheme.error, tokens.card), greaterThanOrEqualTo(4.5));
    }
  });
}

double _contrast(Color a, Color b) {
  final light = math.max(a.computeLuminance(), b.computeLuminance());
  final dark = math.min(a.computeLuminance(), b.computeLuminance());
  return (light + 0.05) / (dark + 0.05);
}
