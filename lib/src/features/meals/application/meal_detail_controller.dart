import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_advisor/src/features/meals/application/meal_repository_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

final mealDetailProvider = FutureProvider.autoDispose.family<MealEntry, String>(
  (ref, id) async {
    final entry = await ref.watch(mealRepositoryProvider).findById(id);
    if (entry == null) throw const MealNotFound();
    return entry;
  },
);

/// Application-facing mutations used by detail and edit screens.
class MealMutations {
  const MealMutations(this._repository);

  final MealRepository _repository;

  Future<MealEntry> update(MealEntry entry) => _repository.update(entry);

  Future<MealEntry> softDelete(MealEntry entry) =>
      _repository.softDelete(id: entry.id, expectedRevision: entry.revision);
}

final mealMutationsProvider = Provider<MealMutations>(
  (ref) => MealMutations(ref.watch(mealRepositoryProvider)),
);

/// In-memory reviewed values used by the saved-meal editor. It never calls an
/// analysis provider; persistence happens only after the user submits the edit.
class MealEditDraftController {
  MealEditDraftController(MealEntry original) : _entry = original;

  MealEntry _entry;
  bool _dirty = false;

  MealEntry get entry => _entry;
  bool get isDirty => _dirty;

  void replaceItem(MealItem item) {
    final index = _entry.items.indexWhere((current) => current.id == item.id);
    if (index < 0) return;
    final items = [..._entry.items]..[index] = item;
    _entry = _copy(items: items);
    _dirty = true;
  }

  void removeItem(String id) {
    if (_entry.items.length == 1) return;
    _entry = _copy(
      items: _entry.items
          .where((item) => item.id != id)
          .toList(growable: false),
    );
    _dirty = true;
  }

  void addItem(String id, {String name = 'New item'}) {
    _entry = _copy(
      items: [
        ..._entry.items,
        MealItem(
          id: id,
          name: name,
          nutrition: NutritionFacts(const {}),
          confidence: MealConfidence.low,
        ),
      ],
    );
    _dirty = true;
  }

  void updateOccurrence(DateTime localOccurrence) {
    final utc = DateTime.utc(
      localOccurrence.year,
      localOccurrence.month,
      localOccurrence.day,
      localOccurrence.hour,
      localOccurrence.minute,
    ).subtract(Duration(minutes: _entry.occurredOffsetMinutes));
    _entry = _copy(occurredAtUtc: utc);
    _dirty = true;
  }

  MealEntry _copy({List<MealItem>? items, DateTime? occurredAtUtc}) =>
      MealEntry(
        id: _entry.id,
        createdAtUtc: _entry.createdAtUtc,
        updatedAtUtc: _entry.updatedAtUtc,
        revision: _entry.revision,
        occurredAtUtc: occurredAtUtc ?? _entry.occurredAtUtc,
        occurredOffsetMinutes: _entry.occurredOffsetMinutes,
        description: _entry.description,
        items: items ?? _entry.items,
        provenance: _entry.provenance,
        userEdited: true,
        confidence: _entry.confidence,
        assumptions: _entry.assumptions,
        deletedAtUtc: _entry.deletedAtUtc,
      );
}
