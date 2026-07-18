# MVP implementation plan

Last updated: 2026-07-18

This plan sequences the accepted product, UI, and technical specifications into
small vertical slices. It is a delivery guide, not a replacement for acceptance
criteria in `specs/`.

Repository-level progress is recorded in
[`implementation-status.md`](implementation-status.md).

## Entry condition

The current specifications are Draft v0.1. Before product behavior is implemented,
the owner should review and mark the relevant specification Accepted. At minimum,
the first product slice depends on accepted versions of:

- `specs/product.md`
- `specs/technical.md`
- `specs/ui-ux.md`
- the feature specification named by the slice

Open visual-brand decisions do not block implementation because the UI plan uses
semantic Material 3 roles and system typography.

## Slice order

Each slice is independently reviewable, contains tests for its behavior, and leaves
the application runnable. Ordinary pull requests target `develop`.

### Slice 0: app foundation and empty Today shell

**Outcome:** the app starts through a testable composition root and shows the
localized, accessible empty Today dashboard shell.

**Includes:**

- bootstrap and production Riverpod composition root
- Material 3 light/dark theme structure and responsive content primitives
- centralized route definitions for Today and Settings placeholders
- injectable `Clock` and `IdGenerator`
- shared failure model and async-state rendering
- initial Today page/view with empty state and record action placeholder
- architecture import test and ARB key-parity test

**Evidence:** English/German widget tests, compact and expanded layout tests, 200
percent text-scale smoke test, analysis and formatting.

### Slice 1: provider credential settings

**Outcome:** a user can securely add, test, replace, and remove a Gemini credential
without exposing it to local data or logs.

**Includes:**

- `CredentialStore` contract and secure-storage adapter
- provider configuration application controller
- provider-neutral connection-check contract and deterministic fake
- Settings and Provider settings screens
- missing, invalid, offline, rate-limited, success, and removal states
- no key value in controller display state after persistence

**Evidence:** credential-store contract tests with an in-memory fake, controller
tests, German/English widget tests, semantic tests, and redaction assertions.

### Slice 2: nutrition domain and local meal persistence

**Outcome:** reviewed meal entries can be stored, observed by local day, edited,
soft-deleted, and restored after database restart.

**Includes:**

- nutrient, meal item, meal entry, provenance, confidence, and assumption models
- decimal-safe calculations and unknown-value aggregation
- `MealRepository` contract
- Drift schema, mappers, transactions, revision and tombstone behavior
- deterministic IDs/timestamps and repository contract suite
- database migration-test harness at schema version 1

**Evidence:** domain validation/aggregation tests, shared repository contract tests
against in-memory Drift, persistence reopen test, and generated-code reproducibility
check.

### Slice 3: text capture, deterministic analysis, review, and save

**Outcome:** using a fake provider, a user can enter text, review an itemized
estimate, correct it, and save it locally.

**Includes:**

- `NutritionAnalysisProvider` contract and provider-neutral analysis models
- description, review, and item-edit controllers as an explicit state machine
- Describe meal, Review estimate, and Edit item screens
- local recalculation after every valid edit
- unknown nutrient values, warnings, assumptions, and confidence presentation
- idempotent confirmation and unsaved-change protection
- deterministic fake provider for tests and development

**Evidence:** validation/controller unit tests; English/German widget tests for
input, loading, review, editing, cancellation, and save failure; Android journey
through save using an in-memory or isolated test database.

### Slice 4: Gemini provider adapter

**Outcome:** configured users can request a validated estimate from the documented
Gemini model while all provider details remain in infrastructure.

**Includes:**

- narrow TLS client owned by the Gemini adapter
- request schema and response DTOs internal to the adapter
- locale instruction and structured response contract
- shape, unit, finite/non-negative, plausibility, and total-consistency validation
- categorized error mapping and credential redaction
- cancellation/timeout behavior where supported
- connection check using the same credential boundary

**Evidence:** sanitized fixture-based contract tests for success, partial/unknown
data, invalid JSON/schema, unsupported units, credential errors, rate limit,
content rejection, and redaction. Live calls remain opt-in and non-blocking.

Any new HTTP or serialization production dependency must be justified and added to
`specs/technical.md` before it is introduced.

### Slice 5: daily dashboard

**Outcome:** Today displays localized totals, incomplete-data states, and the meals
that contribute to the selected local day.

**Includes:**

- observe-day use case with local day-boundary handling
- dashboard display model and controller
- day selector, nutrient overview, all-nutrient section, and entry list
- empty, loading, populated, incomplete, and observation-failure states
- automatic refresh from repository streams after save/edit/delete

**Evidence:** local-day and daylight-saving boundary unit tests, aggregation tests,
English/German widget and golden tests, accessibility semantics, and the integration
journey continuing from capture to updated totals.

### Slice 6: goal configuration and progress

**Outcome:** a user can configure minimum, maximum, or range targets and understand
progress on Today without relying on color.

**Includes:**

- typed goal targets, validation, and progress calculation
- `GoalRepository` contract and Drift adapter
- atomic Goal settings form
- accessible dashboard progress cards and no-goal state
- optional presets only if their numeric values are specified and reviewed

**Evidence:** goal-domain and repository contract tests, form/controller tests,
screen-reader semantics, localized widget/golden tests, and dashboard integration.

### Slice 7: saved meal detail, edit, and delete

**Outcome:** a confirmed entry remains transparent and correctable, and dashboard
totals react immediately to revision or tombstone changes.

**Includes:**

- Meal detail with provenance, assumptions, edited state, and incomplete warnings
- edit flow reusing review/item components without a provider request
- explicit soft-delete confirmation and failure recovery
- occurrence-time edits that can move an entry between local days

**Evidence:** revision/tombstone unit tests, detail/edit/delete widget tests, day
movement test, and extension of the Android persistence journey.

### Slice 8: hardening and MVP acceptance

**Outcome:** all accepted feature criteria have automated evidence and the text MVP
is ready for Android preview testing.

**Includes:**

- full critical Android restart/persistence journey
- golden baselines for required German/English states
- keyboard, rotation, dark theme, text scale, and screen-reader audit
- sensitive logging and fixture audit
- build/release workflow verification
- specification status updates only when every criterion has evidence

Photo capture begins as a new feature slice only after this gate.

## Pull-request boundaries

A slice may use more than one pull request when a change is still independently
valuable, but a pull request should not mix unrelated layers. A typical sequence is:

1. domain contracts and tests
2. infrastructure adapter and contract evidence
3. application controller and state tests
4. localized presentation and widget tests
5. integration-journey extension

Database schema and the repository behavior it supports belong in the same pull
request. Generated output is committed only when the repository convention
requires it and must be reproducible from the documented command.

## Agent-ready work packets

Every implementation task should name:

- the accepted specification section and acceptance criteria in scope
- expected files or owning feature, without prescribing generated output
- interfaces that may change and layers that must not change
- required English and German localization states
- required unit, widget, golden, contract, or integration evidence
- explicit non-goals and any sensitive data involved

Agents should first inspect the current branch and related tests, implement the
smallest complete behavior, and report spec/code mismatches before widening scope.
Unrelated worktree changes must be preserved.

## Standard verification ladder

Run the narrowest relevant test during iteration, then before handoff run:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Run code generation before those gates whenever schemas or generated providers are
changed. Run affected Android integration tests for critical-journey changes. The
pull request should state which commands ran and identify any environment-only gate
that remains for CI.
