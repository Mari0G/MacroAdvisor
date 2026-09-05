import 'dart:typed_data';

import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';

class RetainedMealImage {
  RetainedMealImage({
    required this.mealId,
    required Uint8List jpegBytes,
    required this.width,
    required this.height,
    required this.mimeType,
  }) : assert(mealId != ''),
       assert(jpegBytes.isNotEmpty),
       assert(width > 0),
       assert(height > 0),
       jpegBytes = Uint8List.fromList(jpegBytes);

  final String mealId;
  final Uint8List jpegBytes;
  final int width;
  final int height;
  final String mimeType;
}

abstract interface class MealImageRepository {
  Future<RetainedMealImage?> findByMealId(String mealId);

  Future<void> removeForMeal(String mealId);
}

/// Optional extension of [MealRepository] used by photo confirmation. Keeping
/// it separate preserves the existing repository port for text-only clients.
abstract interface class MealImageAwareMealRepository {
  Future<MealEntry> createWithRetainedImage(
    MealEntryDraft draft,
    RetainedMealImage? image,
  );
}
