import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image;
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';

/// Decode and re-encode every source image before it can reach an AI adapter.
/// Re-encoding strips source metadata and [compute] keeps image work off the UI
/// isolate.
class ImageMealPhotoNormalizer implements MealPhotoNormalizer {
  static const _maximumSourceBytes = 32 * 1024 * 1024;
  static const _maximumEdge = 2048;
  static const _jpegQuality = 88;

  @override
  Future<MealPhoto> normalize(Uint8List sourceBytes) async {
    if (sourceBytes.isEmpty) {
      throw const UnreadableMealPhoto();
    }
    if (sourceBytes.length > _maximumSourceBytes) {
      throw const OversizedMealPhoto();
    }
    if (!_isSupportedSource(sourceBytes)) {
      throw const UnsupportedMealPhoto();
    }
    return compute(_normalize, Uint8List.fromList(sourceBytes));
  }

  static bool _isSupportedSource(Uint8List bytes) =>
      _isJpeg(bytes) || _isPng(bytes) || _isWebP(bytes);

  static bool _isJpeg(Uint8List bytes) =>
      bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff;

  static bool _isPng(Uint8List bytes) =>
      bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47;

  static bool _isWebP(Uint8List bytes) =>
      bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50;

  static MealPhoto _normalize(Uint8List sourceBytes) {
    try {
      final decoded = image.decodeImage(sourceBytes);
      if (decoded == null) {
        throw const UnsupportedMealPhoto();
      }
      var normalized = image.bakeOrientation(decoded);
      if (normalized.width > _maximumEdge || normalized.height > _maximumEdge) {
        normalized = image.copyResize(
          normalized,
          width: normalized.width >= normalized.height ? _maximumEdge : null,
          height: normalized.height > normalized.width ? _maximumEdge : null,
          interpolation: image.Interpolation.average,
        );
      }
      final encoded = Uint8List.fromList(
        image.encodeJpg(normalized, quality: _jpegQuality),
      );
      if (encoded.isEmpty) {
        throw const UnreadableMealPhoto();
      }
      if (encoded.length > MealPhoto.maximumBytes) {
        throw const OversizedMealPhoto();
      }
      return MealPhoto(
        jpegBytes: encoded,
        width: normalized.width,
        height: normalized.height,
      );
    } on MealPhotoFailure {
      rethrow;
    } catch (_) {
      throw const UnsupportedMealPhoto();
    }
  }
}
