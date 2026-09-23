enum AppPalette {
  lime('lime'),
  ocean('ocean'),
  coral('coral'),
  violet('violet');

  const AppPalette(this.id);

  final String id;

  static AppPalette fromStoredId(String? id) {
    for (final palette in values) {
      if (palette.id == id) return palette;
    }
    return lime;
  }
}
