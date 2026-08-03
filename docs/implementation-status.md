# Implementation status

Last updated: 2026-08-03

This tracker records durable delivery progress for the slices in
[implementation-plan.md](implementation-plan.md). It does not replace feature
acceptance criteria. An agent task or worktree is not project-wide status.

## Status vocabulary

- **Planned:** not started on an integration branch.
- **In progress:** active on a working branch.
- **In review:** ready for review or has an open pull request.
- **Merged:** complete evidence is on `develop`.
- **Blocked:** waiting for a recorded product, technical, or external decision.

## Progress

The MVP rows are historical exceptions to the one-feature, one-slice rule for new
features. New rows use one feature ID and one slice ID.

| Slice | Feature | Status | Working branch or PR | Evidence on `develop` | Notes |
| --- | --- | --- | --- | --- | --- |
| S-000 | — | Merged | — | `test/src/app/macro_advisor_app_test.dart`, `test/src/app/architecture_test.dart`, and `test/src/app/localization_parity_test.dart` | Localized Today and Settings shell. Specification status remains independent. |
| S-001 | F-001 | Merged | — | `test/src/features/settings/application/provider_settings_controller_test.dart`, `test/src/features/settings/infrastructure/credential_store_contract_test.dart`, and `test/src/features/settings/presentation/provider_settings_page_test.dart` | Approved and merged as `571b693`; secure credential storage, connection states, removal, redaction, and localized settings evidence are on `develop`. |
| S-002 | F-001, F-002 | Merged | — | `test/src/features/meals/domain/nutrition_test.dart`, `test/src/features/meals/infrastructure/drift_meal_repository_test.dart` | Merged as `8c0fedb`; domain, Drift persistence, repository contract, reopening, and schema-v1 evidence are on `develop`. |
| S-003 | F-001 | Merged | — | `test/src/features/meal_capture/application/capture_controllers_test.dart`, `test/src/features/meal_capture/presentation/meal_capture_flow_test.dart`, and `integration_test/mvp_critical_journey_test.dart` | Approved and merged as `be4803c`; deterministic analysis, capture/review/item-edit controllers, localized flow, save/retry behavior, and the Android persistence journey are on `develop`. |
| S-004 | F-001 | Merged | — | `test/src/features/meal_capture/infrastructure/gemini_nutrition_analysis_provider_test.dart` and sanitized fixtures | Merged via PR #7; Gemini adapter, categorized failures, connection check, validation, redaction, timeout, and Android CI evidence passed. |
| S-005 | F-002 | Merged | — | `test/src/features/dashboard/application/dashboard_controller_test.dart`, `test/src/features/dashboard/presentation/today_page_test.dart`, and `integration_test/mvp_critical_journey_test.dart` | Merged as `86508a1`; local-day selection, aggregation, reactive updates, localized empty/populated/incomplete states, and meal navigation are on `develop`. Goal progress remains part of S-006. |
| S-006 | F-002 | In progress | `codex/slice6-goal-progress` | — | Full format/analyze/unit/widget gate passes; Android integration is blocked locally because Gradle has no configured JDK. |
| S-007 | F-001, F-002 | Merged | — | `test/src/features/meals/application/meal_detail_controller_test.dart` and `test/src/features/meals/presentation/meal_detail_page_test.dart` | Merged as `86508a1`; saved-meal transparency, local edits without re-analysis, soft-delete confirmation, and recoverable delete failure are on `develop`. |
| S-008 | F-001, F-002 | In review | `codex/slice8-hardening` | — | Deterministic Android save/edit/day-move/restart hardening passes locally on an Android emulator; accessibility evidence remains explicitly deferred. |
| S-009 | F-003 | In review | `feat/s-009-photo-capture` | — | Full local gate and deterministic Android library/camera journeys pass; draft PR pending. |
| S-010 | F-001 | Planned | — | — | Permits unknown/noncanonical item amount units as descriptive, non-fatal values; adds a distinct `AnalysisTimedOut` provider failure and localized recovery. |
| S-011 | Planned feature | Planned | — | — | Reserved for configurable nutrient goals and maximums, contextual Today progress, and charted history. Detailed feature specification and slice plan are pending. |
| S-012 | Planned feature | Planned | — | — | Reserved for opt-out local retention of a small, low-resolution food image. It requires an accepted revision to F-003's current no-image-persistence requirement before implementation. |
| S-013 | — | Planned | — | — | Reserved maintenance slice for compact, expandable warning and information UI and visual-spacing fixes. Detailed slice plan is pending. |

## Update rules

- Update the slice row on its working branch after work starts.
- Mark a slice **In review** only after its required local evidence passes.
- Mark it **Merged** only in the merge that puts its behavior and evidence on
  `develop`.
- Link committed repository evidence, never chat output or uncommitted results.
- A feature specification becomes **Implemented** only when all of its acceptance
  criteria have automated evidence.
- Update the delivery plan before this tracker when delivery scope changes.
