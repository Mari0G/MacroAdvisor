# Delivery plan

Last updated: 2026-08-03

This plan turns accepted specifications into reviewable delivery slices. It does
not replace feature acceptance criteria. Progress and merged evidence live in
[implementation-status.md](implementation-status.md).

## How new features are delivered

Before implementation, a new product feature must have:

1. an accepted feature specification with a permanent `F-###` ID;
2. exactly one planned delivery slice with a permanent `S-###` ID; and
3. a row in the implementation-status tracker.

One slice may use several focused pull requests, but every pull request uses the
same slice ID. Include shared infrastructure in the slice for the feature it
enables. Work with no product feature belongs to maintenance, not a feature
slice.

The MVP slices below predate this rule. They keep their original scope and may
relate to more than one feature.

## Entry condition

Start only from accepted product, technical, UI, quality, and feature
specifications. Use the feature acceptance criteria as the behavior source of
truth, [quality.md](../specs/quality.md) for required evidence, and
[branching.md](branching.md) for branches and pull requests.

## MVP slice order

Each slice is independently reviewable, tested, and leaves the app runnable.
The feature IDs shown here are historical relationships, not new one-to-one
assignments.

### S-000 — App foundation and empty Today shell

**Feature:** none (MVP foundation)

**Outcome:** The app starts through a testable composition root and shows the
localized, accessible empty Today dashboard shell.

**Includes:** app bootstrap; Riverpod composition root; Material 3 theme and
responsive primitives; Today and Settings placeholders; injectable `Clock` and
`IdGenerator`; shared failures and async states; architecture and ARB parity
tests.

**Evidence:** English/German widget tests, compact and expanded layouts, 200%
text-scale smoke test, analysis, and formatting.

### S-001 — Provider credential settings

**Feature:** F-001 (historical support)

**Outcome:** A user can securely add, test, replace, and remove a Gemini
credential without exposing it to local data or logs.

**Includes:** `CredentialStore`; provider configuration controller; connection
check contract and fake; Settings and Provider settings screens; all connection
states; no stored key in display state.

**Evidence:** credential-store contract, controller, localized widget, semantic,
and redaction tests.

### S-002 — Nutrition domain and local meal persistence

**Features:** F-001, F-002 (historical shared foundation)

**Outcome:** Reviewed meal entries can be stored, observed by local day, edited,
soft-deleted, and restored after a database restart.

**Includes:** meal and nutrient models; decimal-safe calculations; unknown-value
aggregation; `MealRepository`; Drift schema, mappers, transactions, revisions,
and tombstones; deterministic IDs/timestamps; schema-v1 migration harness.

**Evidence:** domain, repository-contract, persistence-reopen, and generated-code
reproducibility tests.

### S-003 — Text capture, deterministic analysis, review, and save

**Feature:** F-001 (historical)

**Outcome:** Using a fake provider, a user can enter text, review an itemized
estimate, correct it, and save it locally.

**Includes:** `NutritionAnalysisProvider`; analysis models; explicit capture,
review, and item-edit state machines; capture screens; local recalculation;
warnings, assumptions, confidence, idempotent save, and unsaved-change handling.

**Evidence:** validation and controller tests; localized widget tests for input,
loading, review, editing, cancellation, and save failure; Android save journey.

### S-004 — Gemini provider adapter

**Feature:** F-001 (historical)

**Outcome:** Configured users can request a validated estimate from the documented
Gemini model while provider details stay in infrastructure.

**Includes:** adapter-owned TLS client; internal request and response types;
locale instruction; structured response validation; categorized errors and
redaction; supported cancellation/timeout behavior; connection check.

**Evidence:** sanitized fixture contract tests for valid, partial, invalid,
unsupported-unit, credential, rate-limit, rejected-content, and redaction cases.
Live calls are opt-in and non-blocking.

Document any new HTTP or serialization production dependency in
[technical.md](../specs/technical.md) before adding it.

### S-005 — Daily dashboard

**Feature:** F-002 (historical)

**Outcome:** Today shows localized totals, incomplete-data states, and the meals
that contribute to the selected local day.

**Includes:** observe-day use case; dashboard model and controller; day selector;
nutrient and entry views; empty, loading, populated, incomplete, and failure
states; repository-driven refresh after changes.

**Evidence:** local-day and daylight-saving tests, aggregation tests, localized
widget/golden tests, accessibility semantics, and capture-to-dashboard journey.

### S-006 — Goal configuration and progress

**Delivery note (2026-08-03):** The implementation on
`codex/slice6-goal-progress` was never merged to `develop`. This historical MVP
slice is blocked and its unmerged scope is superseded by F-004/S-011; do not
resume or merge that branch as S-006.

**Feature:** F-002 (historical)

**Outcome:** A user can configure minimum, maximum, or range targets and
understand progress on Today without relying on color.

**Includes:** typed targets; validation and progress calculations;
`GoalRepository` and Drift adapter; atomic Goal settings form; accessible progress
cards; no-goal state; reviewed optional presets.

**Evidence:** domain and repository-contract tests, form/controller tests,
screen-reader semantics, localized widget/golden tests, and dashboard integration.

### S-007 — Saved meal detail, edit, and delete

**Features:** F-001, F-002 (historical)

**Outcome:** A confirmed entry remains transparent and correctable, and dashboard
totals react immediately to revision or tombstone changes.

**Includes:** meal detail with provenance and warnings; edit flow without a
provider request; soft-delete confirmation and recovery; occurrence-time edits
that can move an entry between local days.

**Evidence:** revision/tombstone tests, detail/edit/delete widget tests, day-move
test, and an extended Android persistence journey.

### S-008 — Hardening and MVP acceptance

**Features:** F-001, F-002 (historical MVP gate)

**Outcome:** The remaining non-accessibility MVP hardening criteria have
automated evidence, including native Android coverage for saving and editing
meals, and the text MVP is ready for Android preview testing subject to the
recorded accessibility evidence gap.

**Includes:** a critical Android emulator journey that saves and then edits a
meal; restart/persistence coverage for the saved revision; localized golden
baselines; keyboard, rotation, theme, and text-scale checks; sensitive logging
and fixture audit; and build/release verification. Screen-reader checks and
accessibility tests are not included in this slice.

Photo capture starts as a new feature with its own feature and slice IDs after
this gate.

#### S-008 slice packet

##### Outcome

- **Feature ID:** F-001 and F-002 (historical MVP gate)
- **Slice ID:** S-008
- **User outcome:** A user can save a reviewed text meal, correct that saved
  meal, and retain the corrected record after an app restart; these critical
  flows have deterministic native Android emulator evidence.
- **Specification sections:** F-001 Behavior and Acceptance criteria; F-002
  Behavior and Acceptance criteria; `quality.md` Integration tests and Quality
  gates; `technical.md` Persistence and transaction boundaries; `ui-ux.md`
  Navigation, Privacy and trust requirements, and Acceptance traceability.
- **Acceptance criteria in scope:** F-001 local confirmation survives restart
  and edits recalculate locally without another AI request; F-002 confirmed and
  edited entries refresh the selected day's totals, including when an occurrence
  moves between local days. Existing localized presentation, privacy, and
  failure-state evidence is audited rather than reimplemented.

##### Boundaries

- **Included work or expected files:** Extend
  `integration_test/mvp_critical_journey_test.dart` to drive the production
  navigation stack with the deterministic provider and test seams; save a
  reviewed meal, open its detail, edit a nutrient and occurrence time, save the
  revision, verify Today updates, and recreate the app with the same test
  database before verifying the persisted revision. Update
  `integration_test/README.md` if its native command or prerequisites change.
  Add focused unit/widget or golden tests only where the hardening audit finds a
  missing functional or localized assertion.
- **Interfaces that may change:** Integration-test-only harness and test support;
  no production interface change is planned.
- **Interfaces that must not change:** `MealRepository`, provider contracts,
  credential storage, Drift production schema, and route payload privacy
  boundaries.
- **Non-goals:** Photo capture; new nutrition or goal behavior; provider/model
  changes; production dependency additions; screen-reader checks and all new
  accessibility-specific tests. Because F-002 requires progress to be
  understandable with screen readers, do not update either feature
  specification to **Implemented** until that separate evidence exists.

##### Evidence and handoff

- **Tests:** Run the deterministic Android emulator journey on a connected
  device or emulator. It must prove initial meal save, saved-meal nutrient edit
  without a second provider request, day-total refresh, occurrence-day move,
  and restart persistence of the revised record. Run focused unit/widget/golden
  tests introduced by the audit, followed by formatting, analysis, and the full
  Flutter test suite.
- **Locales, accessibility, and failure states:** Preserve English and German
  localization parity and exercise localized critical presentation baselines.
  Accessibility-specific testing is explicitly deferred; record it as remaining
  evidence rather than treating this slice as full feature acceptance.
- **Sensitive data or credentials:** Use only the deterministic provider and
  fixture credential; assert that neither credentials nor meal descriptions are
  exposed by test output or committed fixtures.
- **Code generation:** Not expected. Run generation only if an audited source
  change modifies a generated input.
- **Environment-only verification:** Native Android integration requires a
  connected emulator/device and a configured JDK/Gradle environment. If absent,
  record the journey as not run with the reason; do not report it as passing.
- **Publication:** Follow `AGENTS.md` and `docs/branching.md`; branch from
  `develop`, target a draft pull request to `develop`, and do not mark S-008
  merged before all scoped evidence is on `develop`.

### S-009 — Photo meal capture

**Feature specification:** [F-003 — Photo meal capture](../specs/features/photo-meal-capture.md)

**Outcome:** A user can take or choose one meal photo, understand and control what
will be sent to the configured provider, review the resulting itemized estimate,
and save corrected nutrition values without the app retaining the photo.

### S-010 — Analysis response resilience

**Feature specification:** [F-001 — Meal capture and analysis](../specs/features/meal-capture-and-analysis.md)

**Outcome:** A valid nutrition estimate remains editable when its item amount
uses an unknown unit, and a provider-response timeout is shown as a distinct,
localized recoverable failure.

### S-011 — Nutrition goals and history

**Feature specification:** [F-004 — Nutrition goals and history](../specs/features/nutrition-goals-and-history.md)

**Outcome:** A user can set daily nutrient targets, understand localized and
accessible progress on Today, and explore local nutrition history by week,
month, or custom date range.

## Reserved future slices

The following slice IDs reserve the agreed delivery order. They are planning
placeholders only: each must receive its feature specification and complete
slice plan in its dedicated planning task before implementation starts.

### S-012 — Local food-image retention

**Feature specification:** To be created (requires a revision to F-003's
privacy and persistence requirements before implementation).

**Outcome:** By default, the app retains a small, low-resolution local food
image for a saved meal, and the user can disable that retention in Settings.

### S-013 — UI cleanup

**Feature:** none (maintenance).

**Outcome:** Warning and information UI uses less space while retaining
expandable detail, and visual spacing defects between interface items are
corrected.

## New-feature checklist

- Assign the next unused `F-###` ID and add it to [the specification index](../specs/README.md).
- Write the feature specification with user outcome, scope, non-goals, behavior,
  edge cases, acceptance criteria, and verification.
- Assign the next unused `S-###` ID, add one slice for that feature here, and add
  its status row.
- Keep the same IDs in implementation tasks, branches, pull requests, tests, and status
  updates. IDs never change or get reused.

## Slice entry format

Keep new feature slices as navigation metadata. The accepted feature specification
is the complete definition; do not repeat its scope, behavior, boundaries,
acceptance criteria, non-goals, or verification details here.

```markdown
### S-### — Slice name

**Feature specification:** [F-### — Feature name](../specs/features/feature-name.md)

**Outcome:** One sentence describing the user-visible result.
```

The detailed S-008 packet remains as a historical MVP exception because that
hardening slice spans older feature specifications. Do not add detailed packets
for one-feature/one-slice work that has its own specification.

Keep unrelated worktree changes intact. Report a spec/code mismatch before
widening the change.

## Verification

Run the narrowest relevant tests while working. Before handoff, use the required
repository checks from [quality.md](../specs/quality.md) and `tools/verify.ps1`.
Run code generation before those checks when schemas or generated providers
change. State commands run and any environment-only gate in the pull request.
