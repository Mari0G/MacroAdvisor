# Quality and test strategy

Status: Accepted v0.1

Last updated: 2026-07-22

## Quality gates

Every pull request must eventually pass:

- deterministic formatting checks
- Flutter static analysis with warnings treated as failures
- unit tests
- widget tests for changed presentation behavior
- architecture and localization consistency checks
- Android integration tests for affected critical journeys

Release candidates additionally require a reproducible signed or unsigned Android
artifact as appropriate for the release channel. Secrets are never available to
pull requests from forks.

## Test layers

### Unit tests

Cover domain calculations, validation, goal progress, repository contracts,
provider response mapping, error mapping, and sync metadata transitions.

### Contract tests

Each `NutritionAnalysisProvider` adapter runs against shared fixtures and the same
provider-neutral behavior suite. Network responses are recorded as sanitized,
hand-reviewed fixtures; live provider calls are opt-in and never required in CI.

### Widget and golden tests

Cover empty, loading, populated, validation, offline, and error states in German
and English. Golden tests pin fonts, locale, device size, and animation state.

### Integration tests

Android integration tests run the production navigation and persistence stack with
a deterministic fake AI provider. Initial critical journey:

1. start with an empty local database
2. enter a text meal
3. receive a deterministic analysis
4. edit one value
5. confirm and save
6. observe updated daily progress
7. restart and verify persistence

### Live smoke tests

Optional scheduled or manual workflows may test real provider sandboxes with
repository secrets. They report compatibility drift but do not block ordinary
pull requests and must not send personal or production meal data.

## CI and release plan

The initial Linux CI checks formatting, analysis, tests, and an Android build.
Android emulator integration tests may use hardware virtualization when available.
iOS compilation requires a macOS runner and is deferred while iOS remains
supported but untested.

Successful `develop` updates produce Android preview artifacts and, once signing is
configured, GitHub Pre-Releases. Stable `vX.Y.Z` tags on `main` trigger artifact
creation and a normal GitHub Release. Store signing and app-store publication
remain separate protected steps until release credentials and distribution accounts
exist. The complete repository workflow is defined in `docs/branching.md`.

## Definition of done

A feature is complete when its acceptance criteria are covered, all quality gates
pass, both locales are present, accessibility labels are included, failure states
are deliberate, and the relevant specification status is updated.
