# Nutrition dashboard

Status: Accepted v0.1

Last updated: 2026-07-22

## User outcome

A user can understand today's intake and progress toward selected nutrient goals
without interpreting raw meal records.

## MVP scope

- daily view using the user's local day boundary
- totals for all core nutrients
- progress against configured daily targets
- list of confirmed entries contributing to the day
- empty and partially configured states

Week and month aggregation follow after the daily view is accepted.

## Behavior

- Totals include confirmed, non-deleted entries whose occurrence timestamp belongs
  to the selected local calendar day.
- Unknown nutrient values remain unknown unless at least one known contribution can
  be shown with an explicit incomplete-data indication.
- Progress uses accessible text as well as color or charts.
- Targets may be minimums, maximums, or ranges; the UI wording reflects the type.
- Editing or deleting an entry refreshes totals without restarting the app.

## Acceptance criteria

- An empty day shows zero recorded entries and a clear entry action.
- Confirming a meal updates the daily totals and relevant goal progress.
- Values use localized number formatting and consistent units.
- Progress is understandable with screen readers and without color perception.
- Incomplete source data is not presented as a complete daily total.
- German and English layouts handle expected text expansion without clipping.

## Verification

- unit tests for local-day grouping, aggregation, unknown values, and goal progress
- widget tests for empty, populated, incomplete, and no-goal states
- golden tests in German and English
- inclusion in the primary Android integration journey
