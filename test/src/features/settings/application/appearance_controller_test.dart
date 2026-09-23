import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/features/settings/application/appearance_controller.dart';
import 'package:macro_advisor/src/features/settings/domain/app_palette.dart';
import 'package:macro_advisor/src/features/settings/domain/appearance_settings.dart';

void main() {
  test('stable IDs and unknown persisted IDs use Lime', () {
    expect(AppPalette.values.map((value) => value.id), [
      'lime',
      'ocean',
      'coral',
      'violet',
    ]);
    expect(AppPalette.fromStoredId('future-palette'), AppPalette.lime);
  });

  test('loads, changes immediately, saves, reverts and retries', () async {
    final settings = _FakeAppearanceSettings();
    final container = ProviderContainer(
      overrides: [appearanceSettingsProvider.overrideWithValue(settings)],
    );
    addTearDown(container.dispose);
    expect(
      container.read(appearanceControllerProvider).palette,
      AppPalette.lime,
    );
    final controller = container.read(appearanceControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(appearanceControllerProvider).loading, isFalse);
    for (final palette in AppPalette.values) {
      if (palette == AppPalette.lime) continue;
      final pending = controller.select(palette);
      expect(container.read(appearanceControllerProvider).palette, palette);
      await pending;
      expect(settings.id, palette.id);
    }
    settings.failSave = true;
    await controller.select(AppPalette.lime);
    expect(
      container.read(appearanceControllerProvider).palette,
      AppPalette.violet,
    );
    expect(container.read(appearanceControllerProvider).saveFailed, isTrue);
    settings.failSave = false;
    await controller.retry();
    expect(
      container.read(appearanceControllerProvider).palette,
      AppPalette.lime,
    );
    expect(settings.id, 'lime');
  });

  test('load failure falls back safely and can retry', () async {
    final settings = _FakeAppearanceSettings()..failLoad = true;
    final container = ProviderContainer(
      overrides: [appearanceSettingsProvider.overrideWithValue(settings)],
    );
    addTearDown(container.dispose);
    container.read(appearanceControllerProvider);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(appearanceControllerProvider).loadFailed, isTrue);
    settings.failLoad = false;
    settings.id = 'ocean';
    await container.read(appearanceControllerProvider.notifier).retry();
    expect(
      container.read(appearanceControllerProvider).palette,
      AppPalette.ocean,
    );
  });
}

class _FakeAppearanceSettings implements AppearanceSettings {
  String id = 'lime';
  bool failLoad = false;
  bool failSave = false;

  @override
  Future<String?> readPaletteId() async {
    if (failLoad) throw StateError('load');
    return id;
  }

  @override
  Stream<String?> observePaletteId() => Stream.value(id);

  @override
  Future<void> savePaletteId(String value) async {
    if (failSave) throw StateError('save');
    id = value;
  }
}
