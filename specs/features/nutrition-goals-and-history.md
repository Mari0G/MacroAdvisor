# Nutrition goals and history

Status: Accepted v0.1

Feature ID: F-004

Last updated: 2026-08-03

## User outcome

A user can set transparent daily nutrition targets, understand progress for the
selected day, and inspect local week, month, or custom-period nutrition patterns
without sending meal data anywhere.

## Scope

- daily targets for any subset of the seven core nutrients
- Off, Minimum, Maximum, and inclusive Range target variants
- atomic local persistence and observation of the active goal set
- contextual progress on Today for configured nutrients, including an explicit
  no-goal invitation when no targets are active
- a pushed History route with a nutrient selector and daily charts for a rolling
  seven-day view, the selected calendar month, and an inclusive custom date range
- accessible textual summaries and day-by-day values for every charted period
- local-day grouping using each meal's recorded occurrence offset

## Non-goals

- nutrition, medical, weight-loss, or diagnosis advice
- target recommendations, presets, profile/body-characteristic calculations, or
  coaching notifications
- historical versions of goals; historical days use the currently active target
- cloud synchronization, export, sharing, or account data
- changes to meal capture, provider behavior, retained-photo policy, or the
  persisted meal schema beyond read support for bounded date queries
- a third-party charting dependency

## Behavior

### Goals

- The Goal settings screen lists every core nutrient and shows its canonical
  localized unit. A nutrient can be Off, Minimum, Maximum, or Range.
- Minimum and Maximum accept finite, non-negative values. Range requires a
  minimum less than or equal to its maximum. Invalid values remain visible with
  localized field-level guidance and cannot be saved.
- Save replaces the complete goal set in one transaction. A failed save leaves
  the previously active set unchanged. Leaving a changed form asks for
  confirmation.
- Goals persist locally across restart. They are ordinary local preferences, not
  credentials, and must not be logged with meal or profile data.

### Today progress

- Today combines the selected local day's nutrient totals with the active goal
  set. A configured nutrient shows its current value, target wording, and a
  status: below minimum, within target, or above maximum. A minimum-only target
  has no above-target state and a maximum-only target has no below-target state.
- An unknown or incomplete nutrient total never receives a complete percentage
  or success state. The card shows the known subtotal, an incomplete label, and
  an explanation that progress cannot be fully determined.
- Changing a meal, changing goals, or changing the selected day refreshes the
  related progress without restarting the app. A future day remains view-only
  for meal capture.
- Every progress card exposes a semantic label containing the nutrient, current
  value, target type and values, data-completeness state, and textual status.
  Color is supplementary only.

### History

- Today exposes a History action that opens a pushed route and preserves Today's
  selected day and scroll position when the user returns.
- History lets the user choose one core nutrient and one period: rolling seven
  local days ending on the selected anchor day, the anchor day's Gregorian
  calendar month, or a user-selected inclusive local-date range. The range form
  rejects an end date before its start date.
- The chart contains one daily value per local day. A day with no confirmed
  entries is a known zero. A day whose entries include an unknown contribution
  is incomplete and is not plotted as a known zero or a complete target result.
- The history summary identifies the selected nutrient, period, days with
  incomplete data, and the highest and lowest complete daily totals when any
  exist. A screen-reader-accessible list provides the date, daily total,
  incomplete state, and current-goal comparison for each day; the chart is not
  the only way to obtain this information.
- Historical goal comparison uses the current goal set. Changing a goal updates
  historical labels and reference lines; the app does not claim to show the goal
  that was active on a past day.
- Empty periods remain usable and state that no meals were recorded. All history
  reads are local and do not call an AI provider.

## Edge cases

- Date grouping uses the recorded occurrence offset, so daylight-saving changes
  and an edited occurrence that moves a meal between local days affect the right
  Today and History totals.
- Soft-deleted meals do not contribute. Restored or edited meals update visible
  totals and charts through repository observation.
- A period containing only incomplete days reports that no complete high/low is
  available rather than inventing a value.
- Extremely long custom ranges remain scrollable and expose the same textual
  data; implementation may virtualize the visual chart but must not discard
  dates or silently aggregate them into a different period.

## Acceptance criteria

- A user can configure Off, Minimum, Maximum, and Range targets for core
  nutrients; invalid values cannot be saved, and a valid multi-nutrient save is
  atomic and survives restart.
- Today updates configured nutrient progress after either a meal change or a
  goal change, with localized target wording that distinguishes minimum,
  maximum, and range targets.
- No-goal, empty-day, incomplete-data, below-target, within-target, and
  above-target states are clear without relying on color and expose meaningful
  semantics.
- A user can open History, select each core nutrient, and inspect rolling-week,
  calendar-month, and valid custom-range daily totals without network access.
- History distinguishes no-entry zero days from incomplete days, omits deleted
  meals, and keeps local-day/DST behavior consistent with Today.
- Charted information has localized textual alternatives, and German and English
  layouts remain usable at the supported widths and 200% text scale.
- No goal, meal, provider credential, or raw chart data is written to logs or
  external services by this feature.

## Verification

- unit tests for target validation, status calculation, date-range construction,
  daily aggregation, incomplete-data behavior, and local-day/DST boundaries
- GoalRepository and bounded MealRepository contract tests, including atomic
  replacement, reopen persistence, soft deletes, and any Drift migration
- controller tests for goal editing, unsaved changes, reactive Today progress,
  period selection, and failure states
- English and German widget/golden tests for every Today progress state and for
  History's empty, populated, incomplete, custom-range, and textual chart data
- semantic widget tests proving that target and chart data are understandable
  without color or visual chart access
- Android integration coverage that saves goals, records or edits a deterministic
  meal, observes Today progress, opens History, and verifies the same local data
  after restart
