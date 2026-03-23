# Design: preflight-en / preflight-fr

Bilingual skill pair for pre-release validation. English: `preflight-en`.
French: `preflight-fr`.

## Origin

Converted from `release-prep` (agent-core internal skill) into a standalone,
project-agnostic skill. The original was tightly coupled to agent-core's
directory layout (`agents/session.md`, `agent-core/skills/`, `CLAUDE.md`).
This version auto-detects project structure instead.

## Core Design

**Purpose:** Validate git state, run quality checks, audit documentation, and
produce a go/no-go readiness report before release. The actual release command
is human-executed only.

**Non-goals:**
- Bumping versions (out of scope, release tooling does this)
- Running the release command (human-only, enforced by design)
- Managing changelogs (separate concern)

## Detection Strategy

The skill auto-detects project characteristics rather than assuming paths:

| What | Detection |
|------|-----------|
| Project type | `pyproject.toml` / `package.json` / `Cargo.toml` |
| Task runner | `just --list` / `make -n` / `npm run` |
| Quality checks | `just precommit` > `just check` > `make check` > `npm test` |
| Pending tasks | `TODO.md` / `agents/session.md` / taskfile patterns |
| Style corpus | `tmp/STYLE_CORPUS` > `STYLE_CORPUS.md` > bundled default |
| Git remote | `origin` > first remote found |

## Documentation Audit Scope

Two audiences (same as original):

1. **Human-facing:** README.md. Audit against commits since last tag, CLI
   help output, project structure, dependencies. Apply style corpus.
2. **Agent-facing:** Skill descriptions, CLAUDE.md fragments, memory indices.
   Only if such files exist in the project.

The skill does not force documentation structure on projects that don't have
it. It audits what exists.

## Naming Rationale

`preflight-en` / `preflight-fr`: "preflight" is an established anglicism in
French DevOps vocabulary. Francophone developers say "preflight" not "pre-vol".
Since the trigger keyword is the same in both languages, the suffix
disambiguates per the bilingual-skill-creator convention.

Research (March 2026): web search confirmed "preflight" is used as-is in
French tech contexts (Kubernetes preflight checks, Adobe Preflight, CLI
tools). "Feu vert" was considered but does not appear in DevOps vocabulary
and would not be a natural trigger for francophone developers.

## Grounding (Phase 0)

Per bilingual-skill-creator methodology: native rewriting outperforms
mechanical translation for procedural text. Supported by MMLU-ProX (EMNLP
2025) and Cross-Lingual Prompt Steerability (Zhang et al., Dec 2025).

The French version is a complete rewrite sharing the same design decisions,
not a translation of the English version.

## References

- `references/documentation.md` -- detailed documentation audit guidance
  (one per language, not shared)
- `references/default-style-corpus.md` -- fallback style reference when
  the project has none (shared content, each version carries its own copy)
