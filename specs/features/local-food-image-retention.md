# Local food-image retention

Status: Accepted v0.1

Feature ID: F-005

Last updated: 2026-08-04

## User outcome

A user can keep a small local food image with a confirmed photo meal by default,
view it in meal detail, remove it from one meal, or disable retention in Settings
and permanently remove all retained meal images without changing nutrition data.

## Scope

- derive a bounded display JPEG only from F-003's normalized in-memory photo
- default-on local retention for newly confirmed photo meals
- display and individual removal in saved meal detail
- a Settings preference that disables future retention and deletes all retained
  images after explicit confirmation
- atomic Drift persistence, migration, cleanup, and German/English accessible UI

## Non-goals

- retaining an original, source-resolution, or provider-uploaded image
- retaining an image before the user confirms the reviewed meal
- backfilling images for existing meals or text-only meals
- editing, replacing, exporting, sharing, backing up, syncing, or uploading a
  retained image
- changing F-003 acquisition, provider request, review/edit, nutrition, or goal
  behavior

## Behavior

1. F-003 derives a second metadata-free JPEG from its normalized image before
   releasing capture media. The candidate has a longest edge of at most 512
   pixels, JPEG quality 70, safe MIME type `image/jpeg`, and is no larger than
   256 KiB. It cannot contain EXIF or source filename/path metadata.
2. The candidate remains only in the in-memory capture session through review.
   It is never put in route state, provider input, logs, diagnostics, fixtures,
   screenshots, or ordinary preferences. Discarding review, cancelling, or
   ordinary process death releases it without persistence.
3. The retention preference defaults to enabled on new and upgraded installs.
   At confirmation, the current preference is read. When enabled, the meal and
   candidate are saved atomically; when disabled or no candidate remains, the
   reviewed meal saves through the unchanged idempotent path with no image.
4. A stored image uses a dedicated local-media row keyed to the meal. It contains
   only the derived JPEG bytes, dimensions, and MIME type. Existing meals are not
   backfilled. A retained image is not added to `MealEntry`, dashboard lists, or
   route arguments; detail loads it through an explicit persistence interface.
5. Meal detail displays a retained image with a non-identifying localized semantic
   label and offers Remove saved image. After a short destructive confirmation,
   removal permanently deletes only that media row and keeps the meal, revisions,
   provenance, and nutrition totals unchanged.
6. Settings explains that Saved meal images is enabled by default. Turning it off
   requires confirmation because it atomically deletes every retained image and
   prevents future retention. The setting action leaves all meals, goals, and
   nutrition values intact. Turning it on later does not restore or backfill any
   image.
7. Soft-deleting a meal removes its retained image in the same transaction.
   Restoring that meal restores nutrition data only. Editing a meal preserves its
   retained image unless the user removes it.

## Error and privacy behavior

- If candidate generation fails validation, the reviewed meal remains confirmable
  without an image and the local failure is not sent to a provider.
- If the atomic save fails, neither a meal nor a retained-image row is committed;
  retry remains idempotent and cannot duplicate media.
- If an individual removal or the Settings bulk removal fails, the UI keeps the
  existing image visible and shows localized retry guidance. It never claims that
  deletion succeeded until persistence confirms it.
- Retained image bytes never enter logs, analytics, crash breadcrumbs, provider
  requests, route state, clipboard actions, exports, fixtures, screenshots, or
  diagnostics. The dedicated local SQLite media row is the sole persistence
  exception to F-003's source-media non-retention rule.
- The gallery original remains read-only. Camera-cache, normalized source, and
  unconfirmed-candidate data are removed best-effort after success, discard, or
  interrupted flows.

## Acceptance criteria

- Given the default setting and a confirmed F-003 photo meal, then its detail
  screen shows one local JPEG no larger than 512 pixels on its longest edge and
  256 KiB, with no EXIF, source filename, or source path.
- Given retention is disabled, when a photo meal is confirmed, then the meal and
  all persistence contain no image while nutrition saving, totals, and idempotent
  retry continue to work.
- Given existing retained images, when the user confirms disabling retention,
  then all retained-image rows are permanently removed and no meal nutrition,
  provenance, revision, or goal data changes.
- Given a retained image, when the user removes it from meal detail or
  soft-deletes its meal, then that image is permanently removed without changing
  the retained meal's nutrition data. Restoring a soft-deleted meal has no image.
- Candidates, source images, paths, filenames, source metadata, and provider
  payloads never occur in SQLite outside the dedicated bounded-media row, logs,
  routes, fixtures, screenshots, analytics, diagnostics, or provider requests.
- Settings, preview disclosure, detail display/removal, confirmations, failures,
  and loading states are localized in German and English, expose meaningful
  semantics, and remain usable at 200% text scale.

## Verification

- domain/application tests for candidate limits, default preference, preference
  races during review, idempotent save, individual removal, and bulk deletion
- Drift repository and migration tests for schema upgrades, atomic meal/media
  transactions, cleanup on soft delete, and no media backfill
- German and English Settings and meal-detail widget/golden/semantic tests for
  enabled, disabled, loading, confirmation, failure, and 200% text-scale states
- deterministic Android F-003 library and camera journeys proving default restart
  persistence, opt-out saving no image, individual removal, and bulk deletion
- privacy audit with synthetic media proving the bounded derivative is only in its
  dedicated media row and all source-media/diagnostic exclusions hold
