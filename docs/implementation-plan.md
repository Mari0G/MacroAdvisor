# MVP delivery plan

Last updated: 2026-07-31

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

**Outcome:** All accepted feature criteria have automated evidence and the text
MVP is ready for Android preview testing.

**Includes:** critical restart/persistence journey; localized golden baselines;
keyboard, rotation, theme, text-scale, and screen-reader audit; sensitive logging
and fixture audit; build/release verification; specification status updates only
after all criteria have evidence.

Photo capture starts as a new feature with its own feature and slice IDs after
this gate.

## New-feature checklist

- Assign the next unused `F-###` ID and add it to [the specification index](../specs/README.md).
- Write the feature specification with user outcome, scope, non-goals, behavior,
  edge cases, acceptance criteria, and verification.
- Assign the next unused `S-###` ID, add one slice for that feature here, and add
  its status row.
- Keep the same IDs in task packets, branches, pull requests, tests, and status
  updates. IDs never change or get reused.

## Slice packet

Use this packet when assigning a slice. Fill it from accepted specifications, not
implementation guesses.

### Outcome

- **Feature ID:**
- **Slice ID:**
- **User outcome:**
- **Specification sections:**
- **Acceptance criteria in scope:**

### Boundaries

- **Included work or expected files:**
- **Interfaces that may change:**
- **Interfaces that must not change:**
- **Non-goals:**

### Evidence and handoff

- **Tests:** unit/contract, widget/golden, and Android journey as applicable
- **Locales, accessibility, and failure states:**
- **Sensitive data or credentials:**
- **Code generation:**
- **Environment-only verification:**
- **Publication:** follow `AGENTS.md` and `docs/branching.md`.

Keep unrelated worktree changes intact. Report a spec/code mismatch before
widening the change.

## Verification

Run the narrowest relevant tests while working. Before handoff, use the required
repository checks from [quality.md](../specs/quality.md) and `tools/verify.ps1`.
Run code generation before those checks when schemas or generated providers
change. State commands run and any environment-only gate in the pull request.
