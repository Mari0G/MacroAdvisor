# Repository guidance for coding agents

## Source of truth

- Read `specs/README.md` and the relevant feature specification before changing
  behavior.
- Treat acceptance criteria as requirements, not suggestions.
- If code and a spec disagree, stop and surface the mismatch before broad changes.
- Do not create or commit Architecture Decision Records.

## Working method

- Automatically use the repository skill at
  `.agents/skills/implement-slice/SKILL.md` whenever a user asks to implement,
  continue, complete, or finish a numbered slice or equivalent feature work.
  The user does not need to name the skill explicitly.
- For those implementation requests, the repository owner authorizes committing,
  pushing the working branch, and opening a draft pull request after required
  local gates pass unless the user opts out. Never auto-merge or mark it ready.
- Follow `docs/branching.md`: branch from `develop` and target ordinary pull
  requests to `develop`.
- Never push directly to the protected `develop` or `main` branches.
- The GitHub skill uses the `gh` CLI, which cannot perform GitHub operations
  from inside the sandbox. Run requested `gh` inspection or publication
  commands with the required escalated approval; do not expose credentials in
  commands, chat, or logs.
- Implement one delivery slice at a time.
- For a new product feature, use its permanent `F-###` feature ID and exactly one
  `S-###` delivery slice from `docs/implementation-plan.md`. The MVP S-000–S-008
  roadmap is a documented historical exception.
- Add or update tests with every behavior change.
- Keep provider, persistence, and UI concerns behind explicit interfaces.
- Make generated code reproducible; never hand-edit generated files.
- Keep German and English localization keys synchronized.
- Do not add production dependencies without documenting their purpose in the
  technical specification.

## Security and privacy

- Never commit or log credentials, personal data, or meal images.
- Store user-supplied provider keys only in platform-backed secure storage.
- Real Gemini calls are permitted for relevant local smoke tests using only the
  repository's fixed synthetic meal description. Never run them in ordinary PR
  CI or expose the configured key in commands, chat, output, or logs.
- Treat AI output as untrusted input and validate it before persistence.
- Keep nutrition estimates editable and display their estimated nature.

## Verification

Use `tools/verify.ps1` for the repository verification ladder. At minimum,
changes must eventually pass formatting, `flutter analyze`, unit/widget tests,
and the relevant Android integration tests.
