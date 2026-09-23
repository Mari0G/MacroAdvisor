import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/settings/domain/app_palette.dart';
import 'package:macro_advisor/src/features/settings/infrastructure/drift_appearance_settings.dart';

void main() {
  test('new database defaults to Lime and survives reopen', () async {
    final directory = await Directory.systemTemp.createTemp(
      'macro_appearance_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');
    final first = AppDatabase.forTesting(NativeDatabase(file));
    final settings = DriftAppearanceSettings(first);
    expect(await settings.readPaletteId(), 'lime');
    await settings.savePaletteId('ocean');
    expect(await settings.observePaletteId().first, 'ocean');
    await first.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(file));
    final reopenedSettings = DriftAppearanceSettings(reopened);
    expect(await reopenedSettings.readPaletteId(), 'ocean');
    await reopenedSettings.savePaletteId('future-palette');
    expect(
      AppPalette.fromStoredId(await reopenedSettings.readPaletteId()),
      AppPalette.lime,
    );
    expect(await reopenedSettings.readPaletteId(), 'future-palette');
    await reopened.close();
  });
}
