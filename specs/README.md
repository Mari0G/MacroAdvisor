# MacroAdvisor specifications

Status: Accepted v0.1

These files are the repository's product and behavior source of truth.

## Specifications

- [Product specification](product.md)
- [Technical specification](technical.md)
- [UI and interaction specification](ui-ux.md)
- [Quality and test strategy](quality.md)
- [AI provider evaluation](research/ai-providers.md)

## Feature specifications

| ID | Feature | Specification |
| --- | --- | --- |
| F-001 | Meal capture and analysis | [features/meal-capture-and-analysis.md](features/meal-capture-and-analysis.md) |
| F-002 | Nutrition dashboard | [features/nutrition-dashboard.md](features/nutrition-dashboard.md) |

## Status vocabulary

- **Draft**: open questions may still change behavior.
- **Accepted**: implementation may start and acceptance criteria are binding.
- **Implemented**: all stated acceptance criteria have automated evidence.
- **Superseded**: replaced by another linked specification.

## Working with features

Every new product feature needs an accepted feature specification before
implementation. Assign it the next unused `F-###` ID and keep that ID if the
feature is renamed, moved, or revised.

Before implementation starts, give the feature exactly one delivery slice with
the next unused `S-###` ID in [the delivery plan](../docs/implementation-plan.md).
One slice may use several focused pull requests, but all use the same slice ID.
Put shared infrastructure in the feature slice it enables; work with no product
feature is maintenance.

Every feature specification defines its user outcome, scope, non-goals, behavior,
edge cases, acceptance criteria, and verification. A feature is not complete
because only its happy path works. Delivery progress and merged evidence belong in
[the implementation-status tracker](../docs/implementation-status.md).

Architecture Decision Records are intentionally kept outside this repository.
Technical constraints that affect current implementation belong in
`technical.md` or the relevant feature specification.
