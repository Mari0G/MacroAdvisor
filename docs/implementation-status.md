# MVP implementation status

Last updated: 2026-07-21

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
| 1. Provider credential settings | Merged | — | `test/src/features/settings/application/provider_settings_controller_test.dart`, `test/src/features/settings/infrastructure/credential_store_contract_test.dart`, and `test/src/features/settings/presentation/provider_settings_page_test.dart` | Approved and merged as `571b693`; secure credential storage, connection states, removal, redaction, and localized settings evidence are on `develop`. |
| 2. Nutrition domain and local meal persistence | Merged | — | `test/src/features/meals/domain/nutrition_test.dart`, `test/src/features/meals/infrastructure/drift_meal_repository_test.dart` | Merged as `8c0fedb`; domain, Drift persistence, repository contract, reopening, and schema-v1 evidence are on `develop`. |
| 3. Text capture, deterministic analysis, review, and save | Merged | — | `test/src/features/meal_capture/application/capture_controllers_test.dart`, `test/src/features/meal_capture/presentation/meal_capture_flow_test.dart`, and `integration_test/mvp_critical_journey_test.dart` | Approved and merged as `be4803c`; deterministic analysis, capture/review/item-edit controllers, localized flow, save/retry behavior, and the Android persistence journey are on `develop`. |
| 4. Gemini provider adapter | Merged | — | `test/src/features/meal_capture/infrastructure/gemini_nutrition_analysis_provider_test.dart` and sanitized fixtures | Merged via PR #7; Gemini adapter, categorized failures, connection check, validation, redaction, timeout, and Android CI evidence passed. |
| 5. Daily dashboard | Merged | — | `test/src/features/dashboard/application/dashboard_controller_test.dart`, `test/src/features/dashboard/presentation/today_page_test.dart`, and `integration_test/mvp_critical_journey_test.dart` | Merged as `86508a1`; local-day selection, aggregation, reactive updates, localized empty/populated/incomplete states, and meal navigation are on `develop`. Goal progress remains part of Slice 6. |
| 6. Goal configuration and progress | Planned | — | — | Depends on the dashboard foundation. |
| 7. Saved meal detail, edit, and delete | Merged | — | `test/src/features/meals/application/meal_detail_controller_test.dart` and `test/src/features/meals/presentation/meal_detail_page_test.dart` | Merged as `86508a1`; saved-meal transparency, local edits without re-analysis, soft-delete confirmation, and recoverable delete failure are on `develop`. |
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
