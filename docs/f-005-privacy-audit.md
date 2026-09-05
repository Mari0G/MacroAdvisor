# F-005 / S-012 privacy evidence

Reviewed 2026-09-05 against `specs/features/local-food-image-retention.md`.

## Automated evidence

- `retention_confirmation_test.dart` exercises real normalization, capture,
  review and Drift persistence with images generated in memory. It checks the
  confirmation-time preference and the separation of provider and retained media.
- `meal_capture_flow_test.dart` checks that cancelling the discard dialog keeps
  the candidate, while confirmed discard releases it even if generation finishes
  later. Neither path persists an unconfirmed meal.
- `image_meal_photo_normalizer_test.dart` checks derivative bounds and empty EXIF.
- Migration fixtures contain SQL and synthetic non-image records only. Upgrade
  tests prove no media backfill and preservation of existing data.
- Localized detail tests inspect widgets and semantics without capturing image
  screenshots or adding image golden files.

## Source inspection

- `ImagePickerMealPhotoSource` reads source bytes inside infrastructure. Camera
  cache cleanup runs in `finally`; ordinary gallery acquisition is read-only.
  Cleanup failures are swallowed without exposing file paths. This is best-effort
  cleanup, not a guarantee of forensic erasure or cleanup after forced termination.
- `PhotoController` retains the derivative only in its private in-memory future.
  Review and item navigation carry no image; detail routes carry a meal ID.
- `GeminiNutritionAnalysisProvider._imageRequestBody` accepts only `MealPhoto`.
  It serializes normalized provider media, with no retained-image repository or
  retention-candidate access.
- `DriftMealRepository` writes retained bytes only to `meal_retained_images`,
  inside the meal-confirmation transaction. The retention settings table stores
  a boolean, and the ordinary meal model has no image field.
- Inspection of capture, meal and routing code found no image logging, analytics,
  clipboard, export or diagnostic sinks. No JPEG/WebP assets were added to Git.

## Limits

This is an application-boundary audit using synthetic media and source inspection.
It does not claim to inspect OS backups, physical SQLite free pages, third-party
provider infrastructure, or user-created screenshots. The deterministic Android
journey requires a connected device; its execution status is recorded separately
in the implementation tracker and pull request.
