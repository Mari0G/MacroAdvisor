import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';

/// Application code depends on this port; production binding is supplied by the
/// composition root and tests replace it at the same boundary.
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  throw UnimplementedError('MealRepository must be provided by the app.');
});
