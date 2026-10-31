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
produce a go/no-go readiness report before release. The report is the
deliverable; whether the release command then runs is a separate decision.

**Execution model:** Both models are legitimate. A human may read the report
and run the release afterwards, or the same agent may run it -- but only when
the request that reached it already asked for a release. The skill never
infers authorization from a passing report alone, which keeps report-and-stop
the default: preflight is often invoked precisely to *ask* whether a release
is possible, and a release is hard to reverse (tag, GitHub release, and a
marketplace push in a second repo).

**Non-goals:**
- Bumping versions (out of scope, release tooling does this)
- Releasing on the skill's own initiative (authorization comes from the
  request, never from a passing report)
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
| gitlore memory store | `git config -f .gitmodules --get submodule.gitlore-memory.path` |

## Clean-Tree Exemption: the gitlore Memory Store

Branch, clean tree and submodules are hard blockers, with exactly one
carve-out: the gitlore memory submodule. In a repo that mounts gitlore,
` M memory` is the resting state, not unfinished work -- nobody commits
inside the store; the parent's pre-commit hook gates it and stages the
moved gitlink into the next parent commit, the release commit included.
Without the carve-out preflight cannot pass in such a repo without a
hand-made commit the release was about to make anyway.

- **One path, detected.** The path comes from the submodule's stable
  registered name (`gitlore-memory`), never a hardcoded `memory`. Empty
  output means no store and no exemption. Every other path -- untracked
  files, other dirty submodules -- remains a finding; a gate that waved
  those through would be broken the other way.
- **Reported, not dropped.** A dirty store appears in the report as
  information, outside the pass/FAIL table: neither silent nor counted as
  a pass.
- **Not a project-specific check.** The rule is universal and inert where
  gitlore is absent, so it does not breach the same-gate-everywhere
  constraint.

Rejected: requiring the store to be committed before passing (the real
precondition -- a fresh approved summary before the next parent commit --
is a commit-time rule gitlore's own hook already enforces, at the right
moment); relaxing the submodule rule in general (only the memory store is
dirty between commits by design).

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
