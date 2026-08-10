import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';

enum MealPhotoSourceType { camera, library }

sealed class MealPhotoAcquisition {
  const MealPhotoAcquisition();
}

final class AcquiredMealPhoto extends MealPhotoAcquisition {
  AcquiredMealPhoto(Uint8List bytes) : bytes = Uint8List.fromList(bytes);

  final Uint8List bytes;
}

final class CancelledMealPhotoAcquisition extends MealPhotoAcquisition {
  const CancelledMealPhotoAcquisition();
}

final class FailedMealPhotoAcquisition extends MealPhotoAcquisition {
  const FailedMealPhotoAcquisition(this.failure);

  final MealPhotoFailure failure;
}

/// Camera/library boundary. Platform types and temporary paths cannot cross it.
abstract interface class MealPhotoSource {
  Future<MealPhotoAcquisition> acquire(MealPhotoSourceType source);

  Future<MealPhotoAcquisition?> recoverLostData();
}

/// Optional platform capability used only after an explicitly permanent denial.
abstract interface class MealPhotoSettingsOpener {
  Future<void> openAppSettings();
}

abstract interface class MealPhotoNormalizer {
  Future<MealPhoto> normalize(Uint8List sourceBytes);
}

final mealPhotoSourceProvider = Provider<MealPhotoSource>((ref) {
  throw UnimplementedError('MealPhotoSource must be provided by the app.');
});

final mealPhotoNormalizerProvider = Provider<MealPhotoNormalizer>((ref) {
  throw UnimplementedError('MealPhotoNormalizer must be provided by the app.');
});
