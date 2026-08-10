# Photo meal capture

Status: Accepted v0.2

Feature ID: F-003

Last updated: 2026-08-04

## User outcome

A user can take a photo of a meal or choose one from the device, receive an
itemized nutrition estimate, correct it, and save the reviewed values without
the app retaining the source photo.

F-003/S-009 governs photo acquisition and analysis. The separately planned
F-005/S-012 feature governs any later local display-image retention.

## Scope

- one still photo from the system camera or system image library
- an in-app preview before analysis, with replace and remove actions
- local image validation, orientation normalization, resizing, and metadata
  removal before upload
- Gemini image analysis through the existing provider-neutral analysis result
- the existing editable review, item-edit, confirmation, and local-save journey
- German and English presentation, permission recovery, and failure states

## Non-goals

- multiple photos for one analysis
- combining a photo with a typed description or follow-up prompt
- crop, markup, filters, barcode scanning, OCR-only label capture, or food-history
  matching
- retaining a thumbnail or original photo with the saved meal in S-009; F-005
  alone may introduce a bounded derivative
- background uploads, provider file storage, or resumable analysis after process
  death
- changing the supported nutrient set or claiming measurement-level accuracy

## Input and analysis contract

The photo acquisition boundary returns a provider-neutral `MealPhoto` containing
only normalized JPEG bytes, dimensions, and the safe MIME type `image/jpeg`.
Platform picker types, source paths, filenames, and metadata do not cross into the
application or provider contract.

Before analysis, the selected image is decoded, corrected for orientation,
resized so its longest edge is at most 2048 pixels, re-encoded as JPEG at a
documented quality setting, and stripped of EXIF and other source metadata. The
normalized payload must be non-empty and no larger than 6 MiB. Source JPEG, PNG,
and WebP files are supported; other formats produce a localized local failure
without a provider request.

`NutritionAnalysisProvider` gains a provider-neutral image method alongside
`analyzeText`. Both methods return the existing validated `NutritionAnalysis`
contract, so review, editing, totals, warnings, confidence, persistence, and
provenance remain shared.

## Behavior

1. Selecting Record meal opens a source chooser with Describe meal, Take photo,
   and Choose photo.
2. Take photo opens the system camera. Choose photo opens the system image
   library and permits exactly one still image.
3. Cancelling either system surface returns to the unchanged source chooser and
   is not shown as an error.
4. A selected image is normalized and shown on a Photo meal screen with the
   occurrence time, privacy/estimate guidance, Replace, Remove, and Analyze
   estimate actions.
5. Analyze is enabled only for a valid normalized photo. Missing provider
   configuration offers the existing provider-settings route and preserves the
   in-memory photo while the process remains alive.
6. The request sends the normalized bytes inline over TLS. It never uses a public
   URL or a provider file-upload API.
7. A successful validated result replaces Photo meal with the existing Review
   estimate flow. The photo is released and is not required for review or save.
8. Recoverable provider failures keep the preview available for retry. Removing
   the photo or leaving the capture flow discards the in-memory payload.
9. Confirming persists only the reviewed nutrition values and standard analysis
   provenance. F-005 may add an optional bounded derivative in its own atomic
   persistence path; this feature never persists a source photo, source path,
   filename, source metadata, or provider payload.
10. If Android recreates the activity while the system picker is open, the app
    recovers the pending picker result. Ordinary process death after selection
    clears the photo draft instead of persisting sensitive media.

## Permission and privacy behavior

- Camera and image-library access is requested only after the corresponding user
  action, using the system picker/camera surface.
- A denied permission produces a localized explanation. A permanently denied
  permission offers an Open settings action; the other source and text entry
  remain available.
- iOS permission-purpose strings exist in English and German. No microphone
  permission is requested because video is out of scope.
- Gallery originals are read-only and never modified or deleted. App-owned camera
  cache files and normalized temporary data are removed on success or discard and
  cleaned up best-effort after interrupted flows.
- Source photos, paths, filenames, byte counts tied to a user image, request
  bodies, and decoded image objects never enter logs, analytics, crash
  breadcrumbs, route state, screenshots, fixtures, or SQLite.
- The preview states plainly that the photo will be sent to the configured AI
  provider for analysis. F-005 may add a separate local-retention disclosure.

## Edge cases

- An unreadable, empty, unsupported, or oversized file fails locally and can be
  replaced without losing the selected occurrence time.
- A photo with no recognizable meal produces a distinct localized recoverable
  state rather than an empty or invented analysis.
- Ambiguous portions, hidden ingredients, mixed dishes, and unclear scale produce
  visible assumptions and appropriately lower confidence.
- Offline, timeout, rate-limit, credential, content-rejection, invalid-response,
  and unknown failures preserve the retryable in-memory photo.
- Repeated Analyze taps cannot start concurrent normalization or provider calls.
- Cancelling analysis never creates a meal and returns to a usable preview when
  cancellation is supported.
- Rotation, app backgrounding, keyboard-free accessibility navigation, and 200%
  text scale preserve the selected occurrence time and usable controls.

## Acceptance criteria

- Given a configured provider, when a user takes or chooses one supported photo,
  then a preview is shown and Analyze produces the same editable itemized review
  contract as text capture.
- The source chooser, preview, privacy guidance, permission recovery, local image
  failures, provider failures, and no-meal state are localized in German and
  English.
- The provider receives one normalized JPEG payload no larger than 6 MiB with no
  source EXIF metadata, filename, or device path.
- Cancelling the picker is neutral; denying one source leaves the other source and
  text capture available.
- Android activity recreation while the system picker is open recovers the
  selected photo or a categorized picker failure.
- Editing the resulting items updates totals locally without a second AI request,
  and confirming saves exactly the reviewed values through the existing
  idempotent save path.
- Discarding, cancelling, failing, or confirming never changes daily totals unless
  the user confirms a reviewed estimate.
- After success or discard, no source photo, source path, filename, source
  metadata, or unconfirmed image exists in meal persistence, routes, logs, or
  committed fixtures. F-005 defines the only allowed persisted derivative.
- Camera/photo actions, preview, replace/remove controls, progress, failures, and
  completion have localized accessible names and a logical focus order at 200%
  text scale.

## Verification

- unit tests for normalization limits, metadata removal, cleanup, state
  transitions, request concurrency, and error mapping
- contract tests proving the deterministic and Gemini adapters implement the same
  image-analysis contract with synthetic, metadata-tagged fixtures
- German and English widget/golden tests for source selection, preview, analysis,
  permission denial, local validation, provider recovery, and accessibility
- Android integration journeys for both a synthetic library photo and a
  test-controlled camera result through review, edit, save, Today refresh, and
  restart persistence of nutrition values only for S-009; F-005 adds separate
  retained-image coverage
- a privacy audit asserting that source photos, paths, filenames, and inline
  request data are absent from logs, routes, database rows, screenshots, and
  committed output
