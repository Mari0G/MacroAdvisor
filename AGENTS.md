# Repository guidance for coding agents

## Source of truth

- Read `specs/README.md` and the relevant feature spec before changing behavior.
- Treat acceptance criteria as requirements, not suggestions.
- If code and a spec disagree, stop and surface the mismatch before broad changes.
- Do not create or commit Architecture Decision Records.

## Working method

- Follow `docs/branching.md`: branch from `develop` and target ordinary pull
  requests to `develop`.
- Never push directly to the protected `develop` or `main` branches.
- Implement one vertical slice at a time.
- Add or update tests with every behavior change.
- Keep provider, persistence, and UI concerns behind explicit interfaces.
- Make generated code reproducible; never hand-edit generated files.
- Keep German and English localization keys synchronized.
- Do not add production dependencies without documenting their purpose in the
  technical specification.

## Security and privacy

- Never commit or log credentials, personal data, or meal images.
- Store user-supplied provider keys only in platform-backed secure storage.
- Treat AI output as untrusted input and validate it before persistence.
- Keep nutrition estimates editable and display their estimated nature.

## Verification

The Flutter scaffold will define the exact commands. At minimum, changes must
eventually pass formatting, `flutter analyze`, unit/widget tests, and the relevant
Android integration tests.
