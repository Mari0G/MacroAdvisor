import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/settings/domain/app_palette.dart';
import 'package:macro_advisor/src/features/settings/domain/appearance_settings.dart';

final appearanceSettingsProvider = Provider<AppearanceSettings>(
  (ref) => const _DefaultAppearanceSettings(),
);

final appearanceControllerProvider =
    NotifierProvider<AppearanceController, AppearanceState>(
      AppearanceController.new,
    );

class AppearanceState {
  const AppearanceState({
    this.palette = AppPalette.lime,
    this.loading = true,
    this.saving = false,
    this.loadFailed = false,
    this.saveFailed = false,
    this.retryPalette,
  });

  final AppPalette palette;
  final bool loading;
  final bool saving;
  final bool loadFailed;
  final bool saveFailed;
  final AppPalette? retryPalette;
}

class AppearanceController extends Notifier<AppearanceState> {
  AppPalette _confirmed = AppPalette.lime;

  @override
  AppearanceState build() {
    Future<void>.microtask(load);
    return const AppearanceState();
  }

  Future<void> load() async {
    state = AppearanceState(palette: _confirmed);
    try {
      final id = await ref.read(appearanceSettingsProvider).readPaletteId();
      _confirmed = AppPalette.fromStoredId(id);
      state = AppearanceState(palette: _confirmed, loading: false);
    } catch (_) {
      state = AppearanceState(
        palette: _confirmed,
        loading: false,
        loadFailed: true,
      );
    }
  }

  Future<void> select(AppPalette palette) async {
    if (state.saving || (palette == _confirmed && !state.saveFailed)) return;
    state = AppearanceState(palette: palette, loading: false, saving: true);
    try {
      await ref.read(appearanceSettingsProvider).savePaletteId(palette.id);
      _confirmed = palette;
      state = AppearanceState(palette: palette, loading: false);
    } catch (_) {
      state = AppearanceState(
        palette: _confirmed,
        loading: false,
        saveFailed: true,
        retryPalette: palette,
      );
    }
  }

  Future<void> retry() async {
    final palette = state.retryPalette;
    if (palette == null) return load();
    return select(palette);
  }
}

final class _DefaultAppearanceSettings implements AppearanceSettings {
  const _DefaultAppearanceSettings();

  @override
  Future<String?> readPaletteId() async => AppPalette.lime.id;

  @override
  Stream<String?> observePaletteId() => Stream.value(AppPalette.lime.id);

  @override
  Future<void> savePaletteId(String id) async {}
}
