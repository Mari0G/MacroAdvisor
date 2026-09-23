-- Frozen schema v3, independently of the current Drift generator.
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
CREATE TABLE meal_retained_images (
  meal_entry_id TEXT NOT NULL PRIMARY KEY REFERENCES meal_entries(id),
  jpeg_bytes BLOB NOT NULL,
  width INTEGER NOT NULL,
  height INTEGER NOT NULL,
  mime_type TEXT NOT NULL
);
CREATE TABLE meal_image_retention_settings (
  id INTEGER NOT NULL PRIMARY KEY,
  enabled INTEGER NOT NULL CHECK (enabled IN (0, 1))
);
PRAGMA user_version = 3;
