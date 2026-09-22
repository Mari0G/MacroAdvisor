abstract interface class AppearanceSettings {
  Future<String?> readPaletteId();

  Stream<String?> observePaletteId();

  Future<void> savePaletteId(String id);
}
