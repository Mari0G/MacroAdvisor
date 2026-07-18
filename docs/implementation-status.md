# MVP implementation status

Last updated: 2026-07-18

This file records repository-level progress for the slices defined in
[`implementation-plan.md`](implementation-plan.md). It tracks durable state that is
visible from the integration branch; an individual agent task or worktree is not a
project-wide status source.

## Status vocabulary

- **Planned**: the slice has not started on the integration branch.
- **In progress**: implementation is active on a working branch.
- **In review**: implementation is ready for review or has an open pull request.
- **Merged**: the completed slice and its required evidence are on `develop`.
- **Blocked**: progress requires an explicit product, technical, or external
  decision recorded in Notes.

## Progress

| Slice | Status | Working branch or PR | Evidence on `develop` | Notes |
| --- | --- | --- | --- | --- |
| 0. App foundation and empty Today shell | Merged | — | `test/src/app/macro_advisor_app_test.dart`, `test/src/app/architecture_test.dart`, and `test/src/app/localization_parity_test.dart` | Localized Today and Settings shell. Specification status remains independent. |
| 1. Provider credential settings | In review | `feat/provider-credential-settings` | — | Controller, contract, and English/German widget tests pass locally; ready for review. |
| 2. Nutrition domain and local meal persistence | Merged | — | `test/src/features/meals/domain/nutrition_test.dart`, `test/src/features/meals/infrastructure/drift_meal_repository_test.dart` | Merged as `8c0fedb`; domain, Drift persistence, repository contract, reopening, and schema-v1 evidence are on `develop`. |
| 3. Text capture, deterministic analysis, review, and save | In review | `feat/text-meal-entry` | — | Deterministic provider, capture/review/item-edit controllers, localized flow, and save/retry evidence pass locally. Android integration coverage remains deferred until the integration-test scaffold exists. |
| 4. Gemini provider adapter | Merged | — | `test/src/features/meal_capture/infrastructure/gemini_nutrition_analysis_provider_test.dart` and sanitized fixtures | Merged via PR #7; Gemini adapter, categorized failures, connection check, validation, redaction, timeout, and Android CI evidence passed. |
| 5. Daily dashboard | Planned | — | — | Depends on local meal persistence; sequence after Slice 4 keeps delivery linear. |
| 6. Goal configuration and progress | Planned | — | — | Depends on the dashboard foundation. |
| 7. Saved meal detail, edit, and delete | Planned | — | — | Depends on meal persistence and dashboard observation. |
| 8. Hardening and MVP acceptance | Planned | — | — | Begins after Slices 0–7 are merged. |

## Update rules

- The agent implementing a slice updates its row in the same working branch.
- A slice is marked **In progress** only after implementation work has begun.
- A slice is marked **In review** only when its documented narrow verification
  passes and the change is ready for review.
- A slice is marked **Merged** only in the merge that places the completed behavior
  and required evidence on `develop`.
- Evidence links name committed test files or other repository artifacts, not chat
  messages or uncommitted local output.
- Specification status remains independent. A feature specification becomes
  **Implemented** only when all of its acceptance criteria have automated evidence.
- If plans change, update the plan first and then bring this table into sync in the
  same change.
