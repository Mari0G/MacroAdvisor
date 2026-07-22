---
name: implement-slice
description: Implement, verify, review, and publish a MacroAdvisor vertical slice. Use whenever a user asks to implement, continue, complete, or finish a numbered slice from docs/implementation-plan.md, or requests feature work tied to its acceptance criteria. Apply automatically even when the user does not name the skill.
---

# Implement a slice

Deliver one reviewable vertical slice from accepted specifications through a draft pull request. Keep one primary agent accountable for writes and integration.

## Preflight

1. Read `AGENTS.md`, `specs/README.md`, `docs/implementation-plan.md`, `docs/implementation-status.md`, and the relevant feature specification in full. Read only the sections of product, technical, UI, and quality specifications routed by that feature and slice.
2. Convert the request into the fields in `docs/agent-task-template.md`. Infer safe details from the specifications; ask only when a missing choice materially changes behavior.
3. Confirm the product, technical, UI, quality, and relevant feature specifications have `Accepted` status. Stop and report any unaccepted requirement or spec/code mismatch before broad edits.
4. Inspect Git status and preserve unrelated changes. If the current branch is not the requested slice branch or unrelated changes are present, do not absorb, move, discard, or commit them; create an isolated branch/worktree from current `develop` when safe, otherwise stop and request disposition.
5. Work from current `develop` on one short-lived branch allowed by `docs/branching.md`; never push directly to `develop` or `main`.
6. Check that authenticated draft-PR publication is available before long implementation work. Report an unavailable publication path early, but continue locally unless the user made publication a hard requirement.
7. Identify the narrow tests to run during implementation and whether code generation or an Android journey is affected.

### Cross-spec routing

Always inspect Product `Supported platforms and languages`, `Trust and safety`, `Local-first behavior`, and `Explicit non-goals for the MVP`; Technical `Layer boundaries`, `Error and privacy boundaries`, and `Observability and privacy`; UI `Experience principles`, `Accessibility and localization requirements`, `Privacy and trust requirements`, and `Acceptance traceability`; and Quality `Quality gates` and `Definition of done`.

Add these slice-specific sections:

| Slice | Product | Technical | UI | Quality |
| --- | --- | --- | --- | --- |
| 0 | `MVP outcomes` | `Application stack`, app composition, UI construction, navigation | App bootstrap, Today dashboard | Widget and golden, integration |
| 1 | `MVP outcomes` | app composition, error/privacy, AI integration | Settings, Provider settings, state/recovery | Unit, contract, widget |
| 2 | `Nutrient scope` | domain/application modeling, persistence, domain model | Relevant shared components | Unit, contract |
| 3 | `MVP outcomes`, `Nutrient scope` | domain/application modeling, UI construction, navigation, error behavior | Describe, progress, review, edit item, navigation/recovery | Unit, widget/golden, integration |
| 4 | `Trust and safety` | AI integration, error/privacy, error behavior | Provider recovery and trust states | Contract, live smoke |
| 5 | `Nutrient scope` | domain/application modeling, UI construction, persistence | Today dashboard, recovery | Unit, widget/golden, integration |
| 6 | `Goals` | domain/application modeling, UI construction, navigation, persistence | Today dashboard, Goal settings | Unit, contract, widget/golden, integration |
| 7 | `MVP outcomes` | domain/application modeling, navigation, persistence | Meal detail/edit, navigation/recovery | Unit, widget/golden, integration |
| 8 | All MVP outcomes and non-goals | All affected sections | All acceptance-traceability sections | All test layers and CI/release plan |

## Coordinate agents economically

- Use the primary agent as the only writer by default.
- For a large or ambiguous slice, optionally use one read-only scout to map relevant code, tests, and risks. Give it only the named specifications and owning feature.
- After implementation stabilizes, use one independent read-only reviewer when subagents are available. Give it the acceptance criteria and `develop...HEAD` diff, not the full conversation or the primary agent's conclusions.
- Ask the reviewer only for correctness defects, missing acceptance evidence, security/privacy issues, scope creep, and merge blockers. The primary agent validates and fixes confirmed findings.
- Use parallel writers only for independent file sets with explicit ownership. Do not split the default workflow by domain, persistence, application, and UI layers.
- Run the full verification ladder once per handoff, not once per agent. Allow one review/fix cycle and one focused CI-fix cycle by default.

## Implement

1. Mark the slice `In progress` only after implementation begins.
2. Implement the smallest complete behavior satisfying the selected acceptance criteria.
3. Add or update tests with every behavior change. Keep English and German localization synchronized.
4. Preserve provider, persistence, application, and UI interfaces. Document any new production dependency in `specs/technical.md` before adding it.
5. Treat generated files as outputs. When their inputs change, run the documented generator and verify reproducibility.
6. Run narrow tests while iterating:

   ```powershell
   .\tools\verify.ps1 -Mode Narrow -DartPath <changed.dart> -TestPath <focused_test.dart>
   ```

## Review and verify

1. Freeze the intended diff and run the independent review described above. If subagents are unavailable, perform the same checklist as a fresh pass over `develop...HEAD`.
2. Resolve confirmed blockers and rerun affected narrow tests.
3. Run one handoff gate:

   ```powershell
   .\tools\verify.ps1 -Mode Full
   ```

4. For a changed user journey, also run:

   ```powershell
   .\tools\verify.ps1 -Mode Integration -IntegrationTarget integration_test/mvp_critical_journey_test.dart
   ```

5. Mark the slice `In review` only when required local evidence passes. Never mark it `Merged` before the change reaches `develop`.

## Publish

Per the durable authorization in `AGENTS.md`, unless the user opts out of publication, a slice implementation request includes authorization to:

1. Confirm that the diff contains only the requested slice.
2. Commit the completed change intentionally and push the working branch.
3. Open a **draft** pull request targeting `develop`; never enable auto-merge or merge it.
4. Populate the pull request using `.github/pull_request_template.md`, including specifications, acceptance criteria, non-goals, commands run, and environment-only checks.
5. Observe the initial CI result. If it fails for a branch-owned defect, perform at most one focused repair and push; otherwise report the failure clearly.

At handoff, report the branch, draft PR, implemented criteria, verification evidence, reviewer findings, and any remaining environment-only gate.
