# MacroAdvisor specifications

Status: Accepted v0.1

These files are the repository's product and behavior source of truth.

## Specifications

- [Product specification](product.md)
- [Technical specification](technical.md)
- [UI and interaction specification](ui-ux.md)
- [Quality and test strategy](quality.md)
- [Meal capture and analysis](features/meal-capture-and-analysis.md)
- [Nutrition dashboard](features/nutrition-dashboard.md)
- [AI provider evaluation](research/ai-providers.md)

## Status vocabulary

- **Draft**: open questions may still change behavior.
- **Accepted**: implementation may start and acceptance criteria are binding.
- **Implemented**: all stated acceptance criteria have automated evidence.
- **Superseded**: replaced by another linked specification.

## Specification rules

Every feature specification must define its user outcome, scope, non-goals,
behavior, edge cases, acceptance criteria, and verification approach. A feature is
not complete merely because its happy path works.

Architecture Decision Records are intentionally kept outside this repository.
Technical constraints that affect current implementation belong in
`technical.md` or the relevant feature specification.
