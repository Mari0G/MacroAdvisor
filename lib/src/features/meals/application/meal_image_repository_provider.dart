import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_image.dart';

final mealImageRepositoryProvider = Provider<MealImageRepository>((ref) {
  return const _EmptyMealImageRepository();
});

final class _EmptyMealImageRepository implements MealImageRepository {
  const _EmptyMealImageRepository();

  @override
  Future<RetainedMealImage?> findByMealId(String mealId) async => null;

  @override
  Future<void> removeForMeal(String mealId) async {}
}
