-- Historical schema v2: commit 8b953bc, meal_tables.dart and app_database.dart.
-- Frozen independently of current Drift tables so migrations exercise old layouts.
CREATE TABLE meal_entries (
  id TEXT NOT NULL PRIMARY KEY,
  occurred_at_utc INTEGER NOT NULL,
  occurred_offset_minutes INTEGER NOT NULL,
  description TEXT,
  provider_id TEXT NOT NULL,
  model_id TEXT NOT NULL,
  analyzed_at_utc INTEGER NOT NULL,
  detected_locale TEXT NOT NULL,
  confidence TEXT NOT NULL,
  assumptions_json TEXT NOT NULL,
  user_edited INTEGER NOT NULL CHECK (user_edited IN (0, 1)),
  created_at_utc INTEGER NOT NULL,
  updated_at_utc INTEGER NOT NULL,
  deleted_at_utc INTEGER,
  revision INTEGER NOT NULL
);
CREATE TABLE meal_items (
  id TEXT NOT NULL PRIMARY KEY,
  meal_entry_id TEXT NOT NULL REFERENCES meal_entries(id),
  sort_order INTEGER NOT NULL,
  name TEXT NOT NULL,
  amount_description TEXT,
  normalized_grams_milli INTEGER,
  confidence TEXT NOT NULL,
  assumptions_json TEXT NOT NULL
);
CREATE TABLE meal_nutrient_values (
  meal_item_id TEXT NOT NULL REFERENCES meal_items(id),
  nutrient_id TEXT NOT NULL,
  unit TEXT NOT NULL,
  milli_units INTEGER,
  source TEXT NOT NULL,
  PRIMARY KEY (meal_item_id, nutrient_id)
);
CREATE TABLE goal_targets (
  nutrient_id TEXT NOT NULL PRIMARY KEY,
  unit TEXT NOT NULL,
  target_kind TEXT NOT NULL,
  minimum_milli_units INTEGER,
  maximum_milli_units INTEGER
);
PRAGMA user_version = 2;
