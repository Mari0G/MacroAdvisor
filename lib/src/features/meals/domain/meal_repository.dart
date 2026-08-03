import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';

abstract interface class MealRepository {
  Future<MealEntry> create(MealEntryDraft draft);

  Future<MealEntry?> findById(String id, {bool includeDeleted = false});

  /// Emits active entries whose recorded local occurrence falls on [localDay].
  Stream<List<MealEntry>> observeDay(DateTime localDay);

  /// Emits active entries whose recorded local occurrence is in the inclusive
  /// bounded range.
  Stream<List<MealEntry>> observeRange(DateTime start, DateTime end);

  /// Replaces an active entry when [entry.revision] matches the stored revision.
  Future<MealEntry> update(MealEntry entry);

  Future<MealEntry> softDelete({
    required String id,
    required int expectedRevision,
  });

  Future<MealEntry> restore({
    required String id,
    required int expectedRevision,
  });
}

class MealRevisionConflict implements Exception {
  const MealRevisionConflict();
}

class MealNotFound implements Exception {
  const MealNotFound();
}
