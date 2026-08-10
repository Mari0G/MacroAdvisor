# Nutrition dashboard

Status: Accepted v0.1

Feature ID: F-002

Last updated: 2026-08-03

## User outcome

A user can understand today's intake without interpreting raw meal records.

## MVP scope

- daily view using the user's local day boundary
- totals for all core nutrients
- list of confirmed entries contributing to the day
- empty and partially configured states

Daily targets, contextual progress, and historical aggregation are defined by
[F-004](nutrition-goals-and-history.md).

## Behavior

- Totals include confirmed, non-deleted entries whose occurrence timestamp belongs
  to the selected local calendar day.
- Unknown nutrient values remain unknown unless at least one known contribution can
  be shown with an explicit incomplete-data indication.
- Editing or deleting an entry refreshes totals without restarting the app.

## Acceptance criteria

- An empty day shows zero recorded entries and a clear entry action.
- Confirming a meal updates the daily totals.
- Values use localized number formatting and consistent units.
- Progress is understandable with screen readers and without color perception.
- Incomplete source data is not presented as a complete daily total.
- German and English layouts handle expected text expansion without clipping.

## Verification

- unit tests for local-day grouping, aggregation, and unknown values
- widget tests for empty, populated, and incomplete states
- golden tests in German and English
- inclusion in the primary Android integration journey
