import 'package:drift/drift.dart';

@DataClassName('MealEntryRow')
class MealEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get occurredAtUtc => dateTime()();
  IntColumn get occurredOffsetMinutes => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get providerId => text()();
  TextColumn get modelId => text()();
  DateTimeColumn get analyzedAtUtc => dateTime()();
  TextColumn get detectedLocale => text()();
  TextColumn get confidence => text()();
  TextColumn get assumptionsJson => text()();
  BoolColumn get userEdited => boolean()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  DateTimeColumn get deletedAtUtc => dateTime().nullable()();
  IntColumn get revision => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MealItemRow')
class MealItems extends Table {
  TextColumn get id => text()();
  TextColumn get mealEntryId => text().references(MealEntries, #id)();
  IntColumn get sortOrder => integer()();
  TextColumn get name => text()();
  TextColumn get amountDescription => text().nullable()();
  IntColumn get normalizedGramsMilli => integer().nullable()();
  TextColumn get confidence => text()();
  TextColumn get assumptionsJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MealNutrientValueRow')
class MealNutrientValues extends Table {
  TextColumn get mealItemId => text().references(MealItems, #id)();
  TextColumn get nutrientId => text()();
  TextColumn get unit => text()();
  IntColumn get milliUnits => integer().nullable()();
  TextColumn get source => text()();

  @override
  Set<Column<Object>> get primaryKey => {mealItemId, nutrientId};
}
