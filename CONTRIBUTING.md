# Contributing to MacroAdvisor

MacroAdvisor uses a spec-driven workflow. Every behavior change starts with an
issue or specification update and ends with automated evidence that the stated
acceptance criteria pass.

## Workflow

1. Select one small, end-to-end user outcome.
2. Add or update its specification and acceptance criteria.
3. Add failing tests that represent the acceptance criteria.
4. Implement the smallest change that satisfies them.
5. Run formatting, static analysis, unit, widget, and relevant integration tests.
6. Update user-facing documentation in both supported languages when needed.

Pull requests should link the relevant specification, state what is deliberately
out of scope, and list the verification commands that were run.

## Product constraints

- Do not present AI-derived nutrition values as exact measurements.
- AI results must remain reviewable and editable before they are saved.
- Never commit API keys, credentials, meal photos, or personal health data.
- Keep German and English behavior at feature parity.
- Preserve offline operation for all non-AI features.
- Do not add cloud synchronization until it has an approved feature spec.

## Architecture records

Architecture Decision Records are intentionally not stored in this repository.
Current architectural constraints belong in the relevant specification. Historical
decision discussions may live in GitHub issues or pull requests.

## License

Contributions are accepted under the Apache License 2.0.
