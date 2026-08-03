import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/core/infrastructure/database/app_database.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_repository.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';

class DriftMealRepository implements MealRepository {
  DriftMealRepository(this._database, this._clock, this._idGenerator);

  final AppDatabase _database;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<MealEntry> create(MealEntryDraft draft) async {
    if (draft.confirmationId != null) {
      final existing = await findById(draft.confirmationId!);
      if (existing != null) return existing;
    }
    final now = _utc(_clock.now());
    final entry = MealEntry(
      id: draft.confirmationId ?? _idGenerator.newId(),
      createdAtUtc: now,
      updatedAtUtc: now,
      revision: 0,
      occurredAtUtc: _utc(draft.occurredAtUtc),
      occurredOffsetMinutes: draft.occurredOffsetMinutes,
      description: draft.description,
      items: draft.items,
      provenance: draft.provenance,
      userEdited: draft.userEdited,
      confidence: draft.confidence,
      assumptions: draft.assumptions,
    );
    await _database.transaction(() async => _insertEntry(entry));
    return entry;
  }

  @override
  Future<MealEntry?> findById(String id, {bool includeDeleted = false}) async {
    final row = await (_database.select(
      _database.mealEntries,
    )..where((entry) => entry.id.equals(id))).getSingleOrNull();
    if (row == null || (!includeDeleted && row.deletedAtUtc != null)) {
      return null;
    }
    return _readEntry(row);
  }

  @override
  Stream<List<MealEntry>> observeDay(DateTime localDay) {
    return _database.select(_database.mealEntries).watch().asyncMap((
      rows,
    ) async {
      final entries = await Future.wait(
        rows.where((row) => row.deletedAtUtc == null).map(_readEntry),
      );
      return entries
          .where((entry) => entry.occursOnLocalDay(localDay))
          .toList(growable: false);
    });
  }

  @override
  Stream<List<MealEntry>> observeRange(DateTime start, DateTime end) {
    final first = DateTime.utc(start.year, start.month, start.day);
    final last = DateTime.utc(end.year, end.month, end.day);
    return _database.select(_database.mealEntries).watch().asyncMap((
      rows,
    ) async {
      if (last.isBefore(first)) return const <MealEntry>[];
      final entries = await Future.wait(
        rows.where((row) => row.deletedAtUtc == null).map(_readEntry),
      );
      return entries
          .where((entry) {
            final local = entry.occurredAtUtc.add(
              Duration(minutes: entry.occurredOffsetMinutes),
            );
            final occurrence = DateTime.utc(local.year, local.month, local.day);
            return !occurrence.isBefore(first) && !occurrence.isAfter(last);
          })
          .toList(growable: false);
    });
  }

  @override
  Future<MealEntry> update(MealEntry entry) async {
    return _database.transaction(() async {
      final existing = await _entryOrThrow(entry.id);
      if (existing.deletedAtUtc != null ||
          existing.revision != entry.revision) {
        throw const MealRevisionConflict();
      }
      final updated = MealEntry(
        id: entry.id,
        createdAtUtc: _utc(existing.createdAtUtc),
        updatedAtUtc: _utc(_clock.now()),
        revision: existing.revision + 1,
        occurredAtUtc: _utc(entry.occurredAtUtc),
        occurredOffsetMinutes: entry.occurredOffsetMinutes,
        description: entry.description,
        items: entry.items,
        provenance: entry.provenance,
        userEdited: entry.userEdited,
        confidence: entry.confidence,
        assumptions: entry.assumptions,
      );
      final existingItems = await (_database.select(
        _database.mealItems,
      )..where((item) => item.mealEntryId.equals(entry.id))).get();
      if (existingItems.isNotEmpty) {
        await (_database.delete(_database.mealNutrientValues)..where(
              (value) =>
                  value.mealItemId.isIn(existingItems.map((item) => item.id)),
            ))
            .go();
      }
      await (_database.delete(
        _database.mealItems,
      )..where((item) => item.mealEntryId.equals(entry.id))).go();
      await (_database.update(_database.mealEntries)
            ..where((row) => row.id.equals(entry.id)))
          .write(_entryCompanion(updated));
      await _insertItems(updated);
      return updated;
    });
  }

  @override
  Future<MealEntry> softDelete({
    required String id,
    required int expectedRevision,
  }) => _setDeletion(id: id, expectedRevision: expectedRevision, deleted: true);

  @override
  Future<MealEntry> restore({
    required String id,
    required int expectedRevision,
  }) =>
      _setDeletion(id: id, expectedRevision: expectedRevision, deleted: false);

  Future<MealEntry> _setDeletion({
    required String id,
    required int expectedRevision,
    required bool deleted,
  }) {
    return _database.transaction(() async {
      final existing = await _entryOrThrow(id);
      if (existing.revision != expectedRevision ||
          (deleted
              ? existing.deletedAtUtc != null
              : existing.deletedAtUtc == null)) {
        throw const MealRevisionConflict();
      }
      final now = _utc(_clock.now());
      final deletedAt = deleted ? now : null;
      final revision = existing.revision + 1;
      final changed =
          await (_database.update(_database.mealEntries)..where(
                (row) =>
                    row.id.equals(id) & row.revision.equals(expectedRevision),
              ))
              .write(
                MealEntriesCompanion(
                  deletedAtUtc: Value(deletedAt),
                  updatedAtUtc: Value(now),
                  revision: Value(revision),
                ),
              );
      if (changed != 1) {
        throw const MealRevisionConflict();
      }
      return (await findById(id, includeDeleted: true))!;
    });
  }

  Future<MealEntryRow> _entryOrThrow(String id) async {
    final row = await (_database.select(
      _database.mealEntries,
    )..where((entry) => entry.id.equals(id))).getSingleOrNull();
    if (row == null) {
      throw const MealNotFound();
    }
    return row;
  }

  Future<void> _insertEntry(MealEntry entry) async {
    await _database.into(_database.mealEntries).insert(_entryCompanion(entry));
    await _insertItems(entry);
  }

  Future<void> _insertItems(MealEntry entry) async {
    for (var index = 0; index < entry.items.length; index++) {
      final item = entry.items[index];
      await _database
          .into(_database.mealItems)
          .insert(
            MealItemsCompanion.insert(
              id: item.id,
              mealEntryId: entry.id,
              sortOrder: index,
              name: item.name,
              amountDescription: Value(item.amountDescription),
              normalizedGramsMilli: Value(item.normalizedGramsMilli),
              confidence: item.confidence.name,
              assumptionsJson: _encodeAssumptions(item.assumptions),
            ),
          );
      for (final nutrient in item.nutrition.values.entries) {
        final value = nutrient.value;
        await _database
            .into(_database.mealNutrientValues)
            .insert(
              MealNutrientValuesCompanion.insert(
                mealItemId: item.id,
                nutrientId: nutrient.key.value,
                unit: value.unit.name,
                milliUnits: Value(
                  value is KnownNutritionValue ? value.milliUnits : null,
                ),
                source: value.source.name,
              ),
            );
      }
    }
  }

  MealEntriesCompanion _entryCompanion(MealEntry entry) =>
      MealEntriesCompanion.insert(
        id: entry.id,
        occurredAtUtc: entry.occurredAtUtc,
        occurredOffsetMinutes: entry.occurredOffsetMinutes,
        description: Value(entry.description),
        providerId: entry.provenance.providerId,
        modelId: entry.provenance.modelId,
        analyzedAtUtc: entry.provenance.analyzedAtUtc,
        detectedLocale: entry.provenance.detectedLocale,
        confidence: entry.confidence.name,
        assumptionsJson: _encodeAssumptions(entry.assumptions),
        userEdited: entry.userEdited,
        createdAtUtc: entry.createdAtUtc,
        updatedAtUtc: entry.updatedAtUtc,
        deletedAtUtc: Value(entry.deletedAtUtc),
        revision: entry.revision,
      );

  Future<MealEntry> _readEntry(MealEntryRow row) async {
    final itemRows =
        await (_database.select(_database.mealItems)
              ..where((item) => item.mealEntryId.equals(row.id))
              ..orderBy([(item) => OrderingTerm.asc(item.sortOrder)]))
            .get();
    final items = await Future.wait(itemRows.map(_readItem));
    return MealEntry(
      id: row.id,
      createdAtUtc: _utc(row.createdAtUtc),
      updatedAtUtc: _utc(row.updatedAtUtc),
      deletedAtUtc: row.deletedAtUtc == null ? null : _utc(row.deletedAtUtc!),
      revision: row.revision,
      occurredAtUtc: _utc(row.occurredAtUtc),
      occurredOffsetMinutes: row.occurredOffsetMinutes,
      description: row.description,
      items: items,
      provenance: MealProvenance(
        providerId: row.providerId,
        modelId: row.modelId,
        analyzedAtUtc: _utc(row.analyzedAtUtc),
        detectedLocale: row.detectedLocale,
      ),
      userEdited: row.userEdited,
      confidence: MealConfidence.values.byName(row.confidence),
      assumptions: _decodeAssumptions(row.assumptionsJson),
    );
  }

  Future<MealItem> _readItem(MealItemRow row) async {
    final nutrientRows = await (_database.select(
      _database.mealNutrientValues,
    )..where((value) => value.mealItemId.equals(row.id))).get();
    final values = <NutrientId, NutritionValue>{
      for (final nutrient in nutrientRows)
        NutrientId(
          nutrient.nutrientId,
          NutritionUnit.values.byName(nutrient.unit),
        ): nutrient.milliUnits == null
            ? UnknownNutritionValue(
                unit: NutritionUnit.values.byName(nutrient.unit),
                source: NutritionValueSource.values.byName(nutrient.source),
              )
            : KnownNutritionValue(
                milliUnits: nutrient.milliUnits!,
                unit: NutritionUnit.values.byName(nutrient.unit),
                source: NutritionValueSource.values.byName(nutrient.source),
              ),
    };
    return MealItem(
      id: row.id,
      name: row.name,
      amountDescription: row.amountDescription,
      normalizedGramsMilli: row.normalizedGramsMilli,
      nutrition: NutritionFacts(values),
      confidence: MealConfidence.values.byName(row.confidence),
      assumptions: _decodeAssumptions(row.assumptionsJson),
    );
  }

  static DateTime _utc(DateTime value) => value.isUtc ? value : value.toUtc();

  static String _encodeAssumptions(List<MealAssumption> assumptions) =>
      jsonEncode(
        assumptions
            .map(
              (assumption) => {
                'code': assumption.code,
                'description': assumption.description,
              },
            )
            .toList(growable: false),
      );

  static List<MealAssumption> _decodeAssumptions(String encoded) {
    final decoded = jsonDecode(encoded) as List<Object?>;
    return decoded
        .map((item) {
          final map = item! as Map<String, Object?>;
          return MealAssumption(
            code: map['code']! as String,
            description: map['description']! as String,
          );
        })
        .toList(growable: false);
  }
}
