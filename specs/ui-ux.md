# UI and interaction specification

Status: Accepted v0.1

Last updated: 2026-08-03

## Purpose

This specification turns the product outcomes into an implementable mobile UI for
the text-entry MVP and its planned photo-capture extension. It defines information
architecture, screen responsibilities, layout, interaction states, accessibility,
and responsive behavior. It does not change the behavior or acceptance criteria
in the feature specifications.

F-004 plans daily goals and local week/month/custom-range history. Account
features and cloud synchronization remain future scope. Photo entry points are
introduced only with F-003/S-009; until then the implemented text-only behavior
remains unchanged.

## Experience principles

- **Estimate, then verify.** AI results are always described as estimates and are
  reviewed before they become records.
- **The user's data stays useful offline.** Existing meals, totals, goals, and
  settings remain available when analysis cannot reach the provider.
- **One obvious next action.** The primary action on the home screen is recording
  a meal. Secondary configuration is available without dominating the dashboard.
- **Neutral language.** Progress is factual and never labels a food or day as good,
  bad, healthy, or unhealthy.
- **Unknown is not zero.** Missing nutrient data stays visually and semantically
  distinct from a measured zero.
- **Correction is ordinary.** Editing an estimate is a normal step, not an error
  path.

## Information architecture

The MVP has one root destination: **Today**. A persistent bottom navigation bar is
not used for only one meaningful destination. The root scaffold contains:

- an app bar with the current day and access to settings
- the daily nutrition dashboard
- the day's confirmed entries
- a floating primary action to record a meal or drink

Settings, goal configuration, History, capture, review, and meal detail are
pushed routes. F-004 adds History from Today's app bar, retaining Today as the
only root destination and avoiding an empty navigation tab.

```text
App start
  |-- Today
  |     |-- Record meal -> Choose input
  |     |                    |-- Describe -> Analyze --|
  |     |                    `-- Photo -> Analyze -----|-> Review -> Saved -> Today
  |     |-- Meal detail -> Edit or delete -> Today
  |     |-- Goal summary -> Goal settings -> Today
  |     |-- History -> Select nutrient and period -> Today
  |     `-- Settings -> Provider / Language
  `-- Bootstrap failure -> Recoverable full-screen state
```

Provider configuration is encouraged but is not a startup gate. A user can open
the app, inspect local data, and configure goals without a network connection or
credential. Submitting a description without a configured provider offers a
direct route to provider settings and preserves the description.

## Shared visual language

The first implementation uses Material 3 components and the system font. Theme
values are semantic rather than feature-specific so dark mode and higher contrast
can be added without rewriting screens.

### Color roles

- `primary`: main actions and selected controls
- `secondary`: informational accents such as confidence
- `surface` and `surfaceContainer*`: page and card hierarchy
- `error`: failures and invalid input only, never goal progress
- `outline`: borders, dividers, and incomplete-data indicators

Goal states must use text and icons in addition to color. Being above or below a
target is not automatically an error color.

### Type and spacing

- Large title: current day or screen purpose
- Title medium: cards and meal names
- Body: descriptions, assumptions, and recovery guidance
- Label: nutrient values, units, timestamps, and field labels
- Base spacing grid: 4 logical pixels; common gaps are 8, 12, 16, and 24
- Minimum interactive target: 48 by 48 logical pixels
- Page horizontal padding: 16 on compact widths, 24 on medium widths
- Readable content width: at most 720 logical pixels for forms and detail pages

Text scale up to 200 percent must remain usable. Fixed-height containers are not
used for localized text. Cards wrap or grow vertically instead of clipping.

### Reusable presentation components

- `AppAsyncView`: consistent loading, error, empty, and data rendering
- `NutrientValueText`: localized value, unknown marker, and unit
- `NutrientProgressCard`: target wording, current value, and accessible progress
- `NutritionHistoryChart`: visual daily values with an equivalent accessible text
  summary and day-by-day list
- `MealEntryCard`: time, description or item summary, energy, and data warnings
- `EstimateNotice`: visible estimate disclaimer and optional confidence summary
- `InlineRecovery`: error explanation with retry or settings action
- `UnsavedChangesDialog`: shared leave-without-saving confirmation
- `DestructiveActionSheet`: explicit delete confirmation

These components own presentation only. They receive display models and callbacks
and do not read repositories or provider adapters.

## Screen specifications

### 1. App bootstrap

**Purpose:** initialize local persistence and ordinary preferences before showing
the app shell.

**Layout:** platform launch screen followed, only when initialization takes long
enough to be perceptible, by a centered app mark and progress indicator.

**States:**

- loading: no actionable controls
- ready: replace bootstrap with Today so Back cannot return to loading
- recoverable failure: short localized explanation and Retry
- unrecoverable local-data failure: explain that local data could not be opened;
  never silently reset or delete data

### 2. Today dashboard

**Purpose:** communicate today's totals, goal progress, and contributing entries.

**Compact layout, top to bottom:**

1. app bar: “Today” plus localized date; settings icon with semantic label
2. optional configuration or incomplete-data banner
3. horizontally scrollable day selector for previous/today/next, with a date picker
4. overview card for energy and selected goal nutrients
5. expandable “All nutrients” section for the seven core nutrients
6. “Meals and drinks” heading with entry count
7. chronological entry list, newest first
8. floating “Record meal” extended action; it may collapse to an icon after scroll

Future days can be inspected but do not show the record action unless product
behavior later supports planning meals. The MVP records entries for today by
default; occurrence time can be corrected during review or meal editing.

**Empty day:** show zero recorded entries, a concise explanation, and an inline
“Record a meal” button in addition to the floating action. Goal cards may still be
shown. Empty totals are zero only because there are no entries, not because source
values are unknown.

**Incomplete data:** show the known subtotal with an “incomplete” label and an info
action explaining which entries have unknown contributions. Do not render the
known subtotal as 100 percent complete data.

**No goals:** show nutrient totals and a compact “Set daily targets” invitation.
Dashboard use never depends on configuring a goal.

**Interactions:**

- tap a nutrient card to see its target definition and contributing meals
- tap an entry to open Meal detail
- pull to refresh re-reads local repositories; it does not call the AI provider
- changing or returning to today updates the title, totals, and entries together
- entry repository updates refresh the visible day without app restart

### 3. Describe meal

**Purpose:** collect a natural-language description without asking the user to
structure the meal manually.

**Layout:**

- app bar with Back and “Describe meal or drink”
- estimate/privacy helper text
- multiline text field with persistent label, example helper, character counter,
  locale-aware keyboard behavior, and clear control
- occurrence row defaulting to now; tap opens date and time controls
- full-width primary “Analyze estimate” button anchored above the safe-area inset

The description field receives initial focus only when that will not obscure
important guidance. The primary action is disabled for whitespace-only input.
Submitted text is trimmed but otherwise preserved exactly for retry.

**Interactions and states:**

- Back with non-empty text asks whether to discard the draft
- submit with no credential shows an inline explanation and “Open provider
  settings”; returning restores the description and occurrence time
- offline, timeout, rate-limit, rejected-content, invalid-response, and unknown
  failures appear inline with a relevant retry or settings action
- repeated taps cannot start concurrent requests
- while analyzing, the text remains visible and selectable; leaving asks whether
  to cancel the request and keep the local draft

Before F-003 is implemented, photo controls remain absent and no disabled camera
button is shown. With F-003, source selection happens before this screen; Describe
meal remains focused on text input.

### 3a. Photo meal

**Purpose:** acquire and preview one meal photo while making provider disclosure
and non-retention clear before analysis.

Selecting Record meal opens a short source chooser with Describe meal, Take photo,
and Choose photo. The chooser uses text and icons, restores focus to Record meal
when dismissed, and does not request permissions before a source is selected.

After a photo is returned, Photo meal contains:

- app bar with Back and “Photo meal or drink”
- a bounded, aspect-preserving preview with a semantic description that does not
  attempt to identify the food
- guidance for a clear, well-lit image and a disclosure that the normalized photo
  is sent to the configured AI provider but not attached to the saved meal
- Replace and Remove actions
- occurrence date/time defaulting to now
- full-width Analyze estimate action above the safe-area inset

**Interactions and states:**

- cancelling the system camera/library returns to the chooser without an error
- local preparation shows progress and prevents repeated source or analyze actions
- unreadable, unsupported, or oversized images show localized inline recovery and
  keep the occurrence time
- missing credentials opens provider settings and restores the in-memory preview
  on return while the process remains alive
- camera/library denial explains the affected source; permanent denial offers
  Open settings while the alternate photo source and Describe meal remain usable
- while analyzing, preview and guidance remain visible, controls become read-only,
  and supported cancellation returns to the preview
- provider failures and no-meal detection preserve the preview for retry or
  replacement
- Back with a selected photo asks whether to discard it; discarding releases
  app-owned temporary media
- success replaces Photo meal with Review estimate, which does not display or
  retain the photo

### 4. Analysis in progress

Analysis normally remains on Describe meal so the original input and recovery
context are stable. The form becomes read-only and shows:

- determinate progress only when real progress exists; otherwise an indeterminate
  indicator
- “Estimating nutrition…” and a note that this may take a moment
- Cancel, when the adapter supports request cancellation; cancellation never saves
  an entry

On success, replace the route with Review estimate. Back then returns to a
preserved Describe draft only when the user explicitly chooses “Edit description”.

### 5. Review estimate

**Purpose:** make the provider result understandable and editable before saving.

**Layout:**

1. app bar with Back and “Review estimate”
2. always-visible `EstimateNotice` with overall confidence and assumptions access
3. non-fatal validation warning cards, if any
4. editable occurrence date/time
5. item cards showing name, reported amount, confidence, and nutrient summary
6. “Add item” secondary action for omitted foods or drinks
7. recalculated totals card covering every core nutrient
8. sticky full-width “Confirm and save” action

Known values show localized numbers and units. Unknown values show a localized
“Unknown” label. Confidence uses plain-language levels plus accessible text; exact
percentages are shown only if the provider-neutral contract genuinely supports
them.

**Interactions:**

- tapping an item opens Edit item
- swipe-to-delete is not used because accidental deletion is hard to discover;
  item removal is an explicit action within Edit item
- edits update local totals immediately and mark the draft as user-edited
- “Edit description” warns that a new analysis will replace unsaved item edits
- Back with any draft asks whether to discard it
- confirm is enabled only with at least one valid item and no blocking validation
  errors
- while saving, disable all mutation actions and show progress in the primary
  button
- a stable draft/confirmation ID makes repeated confirmation idempotent
- save success replaces the review flow with Today and announces success to screen
  readers; save failure stays on Review with all edits intact

### 6. Edit item

**Purpose:** correct one estimated or manually added item without provider access.

**Layout:** a full-screen form on compact devices and a dialog constrained to 640
logical pixels on larger widths. Fields are grouped into identity, quantity, and
nutrients.

- item name, required
- displayed amount and unit, required as a pair
- normalized grams, optional
- energy, protein, carbohydrates, fat, fibre, sugars, and salt
- per-field “Unknown” toggle or clear action; blank does not silently become zero
- assumptions, read-only for provider-derived items
- Save changes and explicit Remove item actions

Decimal parsing follows the active locale. Fields validate on focus loss and on
submit, not on every keystroke. Negative, non-finite, unsupported-unit, and
implausible values show field-level guidance. Plausibility warnings may be
confirmed; structurally invalid values cannot be saved.

### 7. Meal detail and edit

**Purpose:** inspect provenance and correct or delete a previously confirmed entry.

The read view shows occurrence time, user description when present, item cards,
totals, estimate notice, provider/model provenance without credentials, edited
status, assumptions, and incomplete-data warnings.

“Edit meal” enters an editable copy using the same item editor and totals behavior
as Review. Saving increments the local revision and refreshes Today. “Delete meal”
opens a destructive confirmation sheet naming the entry and explaining its effect
on daily totals. Deletion uses repository semantics/tombstones rather than direct
database removal. A failed edit or delete leaves the original visible.

### 8. Goal settings

**Purpose:** configure transparent daily targets without requiring profile data.

**Layout:** core nutrient list with one row per nutrient. Each row supports Off,
Minimum, Maximum, or Range and shows the applicable localized numeric fields and
unit. Presets, when implemented, populate visible editable values; they never save
without confirmation.

Validation requires finite, non-negative values and range minimum less than or
equal to maximum. Save applies the set atomically and returns to Today. Leaving
with changes asks for confirmation.

### 9. History

**Purpose:** reveal local nutrition patterns without presenting estimates as
medical advice.

**Layout:** app bar with back navigation; a nutrient selector; period controls
for rolling seven days, the selected calendar month, and a custom inclusive date
range; a chart; a text summary; and a day-by-day accessible list. The chart is
never the only representation of a value or target comparison.

**States:**

- empty: state that no meals were recorded for the period
- populated: show localized daily values and any current-goal reference
- incomplete: distinguish known subtotals from complete daily values and explain
  that a precise comparison is unavailable
- invalid range: keep entered dates visible with localized field-level guidance
- failure: show a recoverable local-data error and Retry; never call a provider

### 10. Settings

**Purpose:** hold infrequent app and provider configuration.

Sections:

- AI provider: provider name, configuration status, configure/remove action, and
  connection check
- Goals: summary and route to Goal settings
- Language: System default, English, or German
- About: version, privacy summary, open-source licenses, and estimate disclaimer

Settings never displays a stored credential or includes it in screenshots or
copyable diagnostics.

### 11. Provider settings

**Purpose:** securely add, validate, replace, or remove a user-owned provider key.

**Layout:** provider selector when more than one adapter is implemented; otherwise
show the configured provider as text. Include an obscured credential field,
show/hide control, link to provider guidance, Save securely, Test connection, and
Remove credential.

Saving and testing are distinct actions. Save writes to secure storage only. Test
connection returns success or a provider-neutral recoverable error and never logs
or echoes the key. Removing a credential requires confirmation and does not remove
meals, goals, or ordinary preferences.

## Navigation and back behavior

- Today is the only root route and exits the app on Android Back.
- Pushed configuration/detail routes return to their caller and preserve the
  caller's selected day and scroll state where practical.
- Capture is a nested flow: Describe -> Review -> optional Edit item.
- Successful confirmation removes the entire capture stack before revealing Today.
- System Back, app-bar Back, and predictive back follow the same unsaved-change
  rules.
- Dialogs and sheets are used only for short decisions or focused edits; long
  forms are routes on compact screens.

Route state carries stable IDs and small serializable values, never repository
objects, credentials, image bytes, or provider DTOs.

## State and recovery matrix

| Context | State | User-visible behavior | Recovery |
| --- | --- | --- | --- |
| Dashboard | loading | skeleton cards with stable layout | automatic repository result |
| Dashboard | empty | zero entries and record action | record meal |
| Dashboard | incomplete | known subtotal plus incomplete label | inspect contributors |
| Analyze | missing credential | description preserved | open provider settings |
| Analyze | invalid credential | localized explanation | replace/test credential |
| Analyze | offline/timeout | description preserved | retry |
| Analyze | rate limited | description preserved; wait guidance | retry later |
| Analyze | invalid response | no unvalidated draft shown | retry or edit description |
| Review | non-fatal warning | editable warning plus affected item | edit or confirm if valid |
| Save | repository failure | reviewed draft remains | retry save |
| Local store | observation failure | existing screen replaced by recovery | retry; no silent reset |

## Responsive behavior

- **Compact (<600 logical pixels):** single column, full-screen forms, bottom-safe
  primary actions.
- **Medium (600-839):** centered content; dashboard may use two nutrient columns;
  item edit may use a dialog.
- **Expanded (>=840):** dashboard uses a maximum-width two-pane layout with
  progress on the left and meals on the right. Navigation behavior remains the
  same until a real second root destination exists.

Orientation changes preserve draft values and selected day. Keyboard appearance
must not cover the active field or primary action.

## Accessibility and localization requirements

- Every icon-only action has a localized semantic label and tooltip.
- Progress exposes current value, target type/value, and status as one semantic
  description; color is supplemental.
- Loading and save completion changes are announced without repeatedly interrupting
  screen-reader users.
- Reading and focus order follows visual order. Modal focus is trapped and returns
  to the invoking control.
- Nutrient abbreviations are not the sole screen-reader label.
- All copy, field errors, dates, numbers, decimal parsing, and units are localized.
- English and German keys are introduced together. German golden tests use long
  representative strings and 200 percent text scale checks cover critical forms.
- Contrast meets WCAG AA for text and meaningful non-text indicators.

## Privacy and trust requirements

- Meal descriptions are never placed in logs, analytics, crash breadcrumbs, or
  route names.
- Meal photos, thumbnails, paths, filenames, metadata, decoded objects, and inline
  provider payloads are never placed in persistence, logs, analytics, crash
  breadcrumbs, route state, fixtures, or screenshots. The preview explains
  provider transmission and photo non-retention before analysis.
- Credentials never appear in SQLite, ordinary preferences, logs, fixtures,
  screenshots, clipboard actions, or error details.
- Provider/model identifiers may be shown as provenance; credentials and raw
  provider payloads may not.
- The estimate notice is visible before confirmation and retained in saved detail.
- The UI makes clear when totals are incomplete, edited by the user, or based on
  assumptions.

## Acceptance traceability

| Product behavior | Primary UI evidence |
| --- | --- |
| Text description in German or English | Describe meal localized widget tests |
| Editable itemized result | Review estimate and Edit item widget tests |
| Unknown values are not zero | `NutrientValueText` unit/golden tests |
| Assumptions and estimated nature visible | Review estimate golden tests |
| Local totals update after edit | Review controller unit and widget tests |
| Confirmation survives restart | Android integration journey |
| Cancellation does not change totals | controller/repository integration test |
| Recoverable provider failures | Describe meal state-matrix widget tests |
| Daily goal progress is accessible | semantic widget tests and goldens |
| Local nutrition history is accessible | History widget, golden, and semantic tests |
| German text does not clip | localized golden tests at target sizes |
| Photo capture is private and recoverable | source/preview widget tests, adapter contract tests, privacy audit, and Android journeys |

## Deferred decisions

These choices do not block the text-entry delivery slice:

- brand illustration, custom typography, and final marketing color palette
- nutrient contribution drill-down beyond basic meal filtering
- iPad/tablet-specific navigation beyond the responsive layout rules above
