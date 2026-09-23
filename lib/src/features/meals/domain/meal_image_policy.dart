/// Shared bounds for the local display derivative, separate from provider media.
abstract final class MealImagePolicy {
  static const mimeType = 'image/jpeg';
  static const maximumEdge = 512;
  static const maximumBytes = 256 * 1024;
  static const jpegQuality = 70;

  static bool accepts({
    required List<int> bytes,
    required int width,
    required int height,
    required String mime,
  }) =>
      bytes.length >= 3 &&
      bytes.length <= maximumBytes &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff &&
      width > 0 &&
      height > 0 &&
      width <= maximumEdge &&
      height <= maximumEdge &&
      mime == mimeType;
}
