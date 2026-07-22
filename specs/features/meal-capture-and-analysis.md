# Meal capture and analysis

Status: Accepted v0.1

Last updated: 2026-07-22

## User outcome

A user can describe a meal or drink in ordinary German or English, inspect an
AI-generated nutrient estimate, correct it, and save a trustworthy personal record.

## MVP scope

- free-text meal or drink description
- locale-aware analysis
- itemized foods and quantities
- energy, protein, carbohydrates, fat, fibre, sugars, and salt
- confidence and explicit assumptions
- manual correction before confirmation
- local persistence

Photo capture and gallery selection use the same analysis result contract but are
implemented after the text journey is accepted.

## Analysis contract

An analysis contains:

- provider and model identifier
- analysis timestamp
- detected locale
- one or more items
- per-item amounts, nutrients, confidence, and assumptions
- calculated totals
- non-fatal validation warnings

The provider must not invent a precise quantity without expressing the assumption.
Unknown values are represented as unknown, not zero.

## Behavior

1. The user enters a non-empty description.
2. The app checks network availability indirectly by attempting the request.
3. Missing configuration opens a localized path to provider settings.
4. The provider result is validated and presented as an editable draft.
5. The user may change item names, amounts, and nutrient values.
6. Totals recalculate locally after every edit.
7. Confirming persists exactly the reviewed values and their provenance.
8. Cancelling leaves no confirmed meal entry.

## Edge cases

- A description may contain multiple foods and drinks.
- Ambiguous portions produce assumptions and lower confidence.
- Partial provider output remains editable if core validation succeeds.
- Negative, infinite, non-numeric, or unsupported-unit values are rejected.
- A timeout or rate limit keeps the original input available for retry.
- Repeated confirmation cannot create duplicate records.
- Decimal input accepts the conventions of the active locale.

## Acceptance criteria

- Given a configured provider, when a German or English description is submitted,
  then an editable itemized draft is shown in the active app language.
- Every known core nutrient displays a value and unit; unknown values are visibly
  marked instead of displayed as zero.
- Provider assumptions and the estimated nature of the result are visible before
  confirmation.
- Editing an item nutrient immediately updates totals without a second AI request.
- Confirming stores the reviewed values locally and they survive an app restart.
- Cancelling does not alter daily totals.
- Missing or invalid credentials, offline state, rate limiting, and invalid provider
  responses each produce a localized, recoverable state.
- No credential or meal description is emitted to logs during the journey.

## Verification

- unit tests for validation, totals, edits, and error mapping
- shared provider contract tests using sanitized fixtures
- widget tests in German and English
- Android integration test using a deterministic fake provider
