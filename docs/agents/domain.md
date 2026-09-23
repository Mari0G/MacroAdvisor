# Domain Docs

How engineering skills should consume this repository's domain documentation when exploring the codebase.

## Before exploring, read these

- `CONTEXT.md` at the repository root, if present.
- `docs/adr/`: ADRs that affect the area being changed, if present.

If these files do not exist, proceed silently. The `/domain-modeling` skill, reached via `/grill-with-docs` and `/improve-codebase-architecture`, creates them when terms or decisions are actually resolved.

## File structure

This is a single-context repository:

```
/
├── CONTEXT.md
├── docs/adr/
└── src/
```

## Use the glossary's vocabulary

When output names a domain concept, use the term defined in `CONTEXT.md`. If the needed concept is absent, reconsider whether a new term is warranted and note the gap for `/domain-modeling`.

## Flag ADR conflicts

If a proposed change contradicts an existing ADR, surface the conflict explicitly rather than silently overriding it.
