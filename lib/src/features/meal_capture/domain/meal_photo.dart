import 'dart:typed_data';

/// The only image representation allowed across the analysis-provider boundary.
///
/// It contains normalized JPEG data only. Source paths, names, picker objects,
/// and metadata must remain in infrastructure.
class MealPhoto {
  MealPhoto({
    required Uint8List jpegBytes,
    required this.width,
    required this.height,
  }) : assert(jpegBytes.isNotEmpty),
       assert(width > 0),
       assert(height > 0),
       assert(jpegBytes.length <= maximumBytes),
       jpegBytes = Uint8List.fromList(jpegBytes);

  static const mimeType = 'image/jpeg';
  static const maximumBytes = 6 * 1024 * 1024;

  final Uint8List jpegBytes;
  final int width;
  final int height;
}

sealed class MealPhotoFailure implements Exception {
  const MealPhotoFailure();
}

final class UnsupportedMealPhoto extends MealPhotoFailure {
  const UnsupportedMealPhoto();
}

final class UnreadableMealPhoto extends MealPhotoFailure {
  const UnreadableMealPhoto();
}

final class OversizedMealPhoto extends MealPhotoFailure {
  const OversizedMealPhoto();
}

final class PhotoPermissionDenied extends MealPhotoFailure {
  const PhotoPermissionDenied({this.permanentlyDenied = false});

  final bool permanentlyDenied;
}

final class PhotoSourceUnavailable extends MealPhotoFailure {
  const PhotoSourceUnavailable();
}
