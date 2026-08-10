# Contributing to MacroAdvisor

MacroAdvisor uses a spec-driven workflow. Every behavior change starts with an
issue or specification update and ends with automated evidence that the stated
acceptance criteria pass.

## Workflow

1. For a new feature, assign the next `F-###` ID and add an accepted feature
   specification.
2. Add exactly one `S-###` delivery slice for that feature in
   `docs/implementation-plan.md`, then add its row to the status tracker.
3. Add tests for the acceptance criteria and implement the smallest complete
   behavior.
4. Run the required checks and update user-facing documentation in both supported
   languages when needed.

One slice may use several focused pull requests, but each uses the same IDs. Pull
requests should link the feature and slice IDs, state what is out of scope, and
list the checks that ran.

## Device verification and troubleshooting

For every feature that changes a user journey, add or update a deterministic
Android journey in `integration_test/` and run it on an emulator or connected
device before considering the feature verified. This is the default evidence for
confirming that a feature works in the compiled application, not only in a
widget-test environment.

Use deterministic provider, credential, clock, and ID seams in these journeys;
they must never require a real credential, send a real meal description, or make
a network request. Use the real local persistence implementation when the
journey saves data.

When troubleshooting a reported behavior, first reproduce it in the smallest
faithful automated test. If it depends on navigation, platform behavior, or
persistence, add the reproduction to an Android integration journey and run it
through native Android instrumentation. The exact commands are maintained in
[`integration_test/README.md`](integration_test/README.md).

## Device verification and troubleshooting

For every feature that changes a user journey, add or update a deterministic
Android journey in `integration_test/` and run it on an emulator or connected
device before considering the feature verified. This is the default evidence for
confirming that a feature works in the compiled application, not only in a
widget-test environment.

Use deterministic provider, credential, clock, and ID seams in these journeys;
they must never require a real credential, send a real meal description, or make
a network request. Use the real local persistence implementation when the
journey saves data.

When troubleshooting a reported behavior, first reproduce it in the smallest
faithful automated test. If it depends on navigation, platform behavior, or
persistence, add the reproduction to an Android integration journey and run it
through native Android instrumentation. The exact commands are maintained in
[`integration_test/README.md`](integration_test/README.md).

## Branches and releases

Create feature work from `develop` and submit it back to `develop` through a pull
request. Do not push directly to `develop` or `main`. Stable releases are promoted
through a release pull request from `develop` to `main` and a `vX.Y.Z` tag.

The complete branch, merge, preview, stable-release, and hotfix policy is defined
in [docs/branching.md](docs/branching.md).

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
