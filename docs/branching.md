# Branching and release model

This repository uses two protected, long-lived branches and short-lived working
branches. Branch names are lowercase and case-sensitive.

## Long-lived branches

### `main`

`main` contains stable, release-ready code. It is the source of normal GitHub
Releases and must never receive ordinary feature work directly.

### `develop`

`develop` is the integration branch for the next release. Every successful update
is eligible for an Android preview build and GitHub Pre-Release.

## Working branches

Create short-lived branches from `develop` for implementation work using one of
these prefixes:

- `feat/` for product features
- `fix/` for non-urgent defects
- `chore/` for maintenance and tooling
- `docs/` for documentation-only work
- `test/` for test infrastructure or coverage
- `codex/` for coding-agent work when a more specific prefix is not appropriate

Use a concise kebab-case suffix. Feature branches include the delivery slice ID,
for example `feat/s-009-photo-capture`; maintenance branches do not need one.

Delete working branches after their pull requests are merged.

## Documentation-only updates

Documentation-only changes may be made directly on `develop`. They must not
modify application source, tests, generated files, dependencies, build or
release configuration, or committed evidence. A documentation change that
defines product behavior must still follow the specification rules in
`specs/README.md`.

## Normal implementation flow

For implementation work:

1. Create a working branch from the latest `develop`.
2. Open a pull request targeting `develop`.
3. Pass required formatting, analysis, test, and build checks.
4. Resolve review conversations.
5. Squash-merge the pull request into `develop`.
6. Publish a preview only after the resulting `develop` commit passes CI.

Pull requests from forks are treated as untrusted and cannot access release
credentials.

## Preview releases

A successful push to `develop` produces an installable Android preview artifact.
When release signing is configured, it also publishes a GitHub Pre-Release using a
SemVer-compatible identifier such as:

```text
v0.1.0-dev.42
```

The prerelease number is monotonically increasing. Preview and production builds
use separate application identifiers so both can be installed at the same time:

- production: `dev.mari0g.macroadvisor`
- preview: `dev.mari0g.macroadvisor.preview`

Preview releases are for testing and may contain incomplete features.

## Stable releases

1. Prepare a dedicated release pull request from `develop` to `main`.
2. Update and verify the version, changelog, specifications, and release notes.
3. Run the full quality gate against the release pull request.
4. Merge the release pull request with a merge commit, not squash or rebase.
5. Create the matching signed or annotated tag `vX.Y.Z` on the merge commit.
6. The tag workflow builds and publishes the normal GitHub Release.

Stable releases are tag-driven. A non-release commit on `main` does not publish a
new stable version. GitHub Releases and application versions use Semantic
Versioning.

Release pull requests use merge commits deliberately: preserving `develop` as an
ancestor of `main` prevents already released feature commits from reappearing in
later release pull requests.

## Hotfixes

Urgent production fixes branch from `main` as `hotfix/<description>`.

1. Open a pull request from the hotfix branch to `main`.
2. Pass the full quality gate and merge the fix.
3. Create a new patch tag on `main`.
4. Merge `main` back into `develop` with a merge commit.

The back-merge is mandatory so the next normal release retains the hotfix.

## Protection policy

`main` should reject all direct pushes, require pull requests and successful
status checks, require resolved review conversations, reject force pushes and
branch deletion, and apply the rules to administrators when practical.

`develop` should reject direct pushes other than the documented
documentation-only exception. Implementation changes require pull requests,
successful status checks, resolved review conversations, and the same
force-push and branch-deletion protections.

Do not require linear history because release and hotfix synchronization use merge
commits. Human approval requirements may be tightened when the project has enough
maintainers; CI remains required even for a single-maintainer repository.

GitHub branch protection is not currently available for this private repository
on its selected plan. Until server-side rules can be enabled, contributors and
automation must enforce the same policy locally: use a branch and pull request
for implementation work, allow only the documented exception for
documentation-only changes on `develop`, and never push or merge directly to
`main`. The absence of a hosted guard does not relax these rules.

## Merge methods

| Pull request | Target | Method |
| --- | --- | --- |
| Feature, fix, chore, test | `develop` | Squash merge |
| Documentation-only | `develop` | Direct update permitted |
| Release | `main` | Merge commit |
| Hotfix | `main` | Squash merge |
| Hotfix synchronization | `develop` | Merge commit |

## Automation mapping

| Event | Required result |
| --- | --- |
| Pull request to `develop` or `main` | Quality checks and Android test build |
| Successful push to `develop` | Preview artifact and, when signing is available, Pre-Release |
| Tag `vX.Y.Z` on `main` | Stable Android GitHub Release |
| Pull request from a fork | Checks only; no secrets or publishing |

The concrete GitHub Actions triggers, artifact locations, signing-secret setup,
and zero-cost guardrails are documented in
[release-automation.md](release-automation.md).
