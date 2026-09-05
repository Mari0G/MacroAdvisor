import 'dart:typed_data';

import 'package:macro_advisor/src/features/meals/domain/meal_image_policy.dart';

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

/// A second, bounded image representation used only for local retention.
///
/// This type is intentionally distinct from [MealPhoto], which is the provider
/// input. It contains no source path, filename, picker object, or metadata.
class MealPhotoRetentionCandidate {
  MealPhotoRetentionCandidate({
    required Uint8List jpegBytes,
    required this.width,
    required this.height,
  }) : assert(
         MealImagePolicy.accepts(
           bytes: jpegBytes,
           width: width,
           height: height,
           mime: mimeType,
         ),
       ),
       jpegBytes = Uint8List.fromList(jpegBytes);

  static const mimeType = MealImagePolicy.mimeType;
  static const maximumEdge = MealImagePolicy.maximumEdge;
  static const maximumBytes = MealImagePolicy.maximumBytes;

  final Uint8List jpegBytes;
  final int width;
  final int height;
}

final class MealPhotoRetentionFailure extends MealPhotoFailure {
  const MealPhotoRetentionFailure();
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
