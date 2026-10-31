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
and run the release afterwards, or the same agent may run it -- but only on a
request in the user's own words naming the release and its bump. The skill
never infers authorization from a passing report alone, which keeps
report-and-stop the default: preflight is often invoked precisely to *ask*
whether a release is possible, and a release is hard to reverse (tag, GitHub
release, and a marketplace push in a second repo). See **Release Approval**.

**Non-goals:**
- Bumping versions (out of scope, release tooling does this)
- Releasing on the skill's own initiative (authorization comes from the
  request, never from a passing report)
- Managing changelogs (separate concern)

## Release Approval

Preflight ends immediately before a release, so whatever approval it collects
is the approval the release command will be judged on. In Claude Code the
auto-mode classifier gates an outward-facing command on whether a user prompt
requested that action, not on the command string: a release recipe is not
blocked as such, but an agent-authored proposal answered by `ok` carries no
request, and neither does an opening prompt asking for something adjacent --
the readiness pass is exactly what precedes a release without being one.
Observed: a green report, the agent offering `patch` or `minor`, the user
replying `ok`, and `just release patch` denied before anything executed; the
user then ran the same recipe and it landed whole.

- **The answer must name the action.** A passing run ends in one of three
  ways: the release runs because the request already named it and its bump;
  the report closes by asking the user to reply with the bump, so the reply
  is the request; or the agent prints the command for the user to run. The
  agent never picks, recommends or proposes a bump -- each turns the user's
  reply back into a confirmation of the agent's words.
- **A request without a bump still asks.** "Release" alone does not run
  `just release` on its default: a default chosen by omission is still a
  bump the agent picked. This costs a fully non-interactive caller one stop,
  accepted because the bump is the one decision the release cannot infer.
- **The fallback is the user's own command.** When the reply names no bump,
  the command is denied, or the agent cannot run it in this environment, it
  prints the exact command -- in Claude Code prefixed with `!`, so the output
  lands in the conversation and the agent can diagnose from it -- and stops.

Rejected: decomposing the recipe into its `git` / `gh` steps to route around
a denial (a release is one atomic sequence; run by hand it ends half-landed,
version commit and tag public with the GitHub release or marketplace bump
missing -- a dirty stop manufactured to dodge a clean one); re-asking for confirmation (a second agent-authored question has the
provenance defect of the first).

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
| gitlore memory store | `git config -f "$(git rev-parse --show-toplevel)/.gitmodules" --get submodule.gitlore-memory.path` |

## Clean-Tree Exemption: the gitlore Memory Store

Branch, clean tree and submodules are hard blockers, with exactly one
carve-out: the gitlore memory submodule. In a repo that mounts gitlore the
store differs from the parent's HEAD between commits by design, not as
unfinished work. Nobody runs `git commit` inside it: gitlore commits it
through its approval gate and stages the moved pointer in the parent
index, and whatever parent commit comes next records that pointer, the
release commit included. Without the carve-out preflight cannot pass in
such a repo without a hand-made commit the release was about to make
anyway.

- **One path, detected.** The path comes from the submodule's stable
  registered name (`gitlore-memory`), read from the top-level
  `.gitmodules` so the probe does not depend on the working directory --
  never a hardcoded `memory`. Empty output means no store and no
  exemption. Every other path -- untracked files, other dirty
  submodules -- remains a finding; a gate that waved those through would
  be broken the other way.
- **Modified only, not conflicted.** The exemption covers the store's
  modified states (` M`, `M `, `MM` in porcelain; `+` or none in
  submodule status) -- `M ` included, since a staged pointer is what
  gitlore's own commit leaves behind. An unmerged store (`UU`, `AA` ...;
  `U` in submodule status) still fails and points at `/gitlore:resolve`:
  a conflict is unfinished work, and committing over it would record an
  arbitrary side. A checkout behind or beside the recorded pointer shows
  the same `+` but also fails: the store does not move when the parent's
  HEAD does, so after a parent pull or reset the checkout can trail the
  pointer, and committing it would walk the pointer back. Only a
  checkout at or descending from the recorded pointer is exempt.
- **Reported, not dropped.** A modified store appears in the report as
  information, outside the pass/FAIL table: neither silent nor counted
  as a pass.
- **The release recipe must agree.** Preflight passing a modified store
  is only useful if the release then accepts it. A project whose recipe
  refuses any dirty tree has to exclude the same path, and preflight
  reports the mismatch as a clean-tree FAIL rather than pass a release
  that will abort. This repo's `justfile` does so: its `release` guard
  reads the path the same way, runs `git diff --quiet HEAD` with that
  path excluded, refuses an unmerged store or one checked out behind or
  beside its recorded pointer, and `git add`s the store path before the
  release commit -- a no-op when gitlore already staged
  the pointer, and the catch for a pointer whose staging was skipped or
  undone. `git commit` without a pathspec then records it alongside the
  manifests.
- **Not a project-specific check.** The rule is universal and inert where
  gitlore is absent, so it does not breach the same-gate-everywhere
  constraint.

Rejected: requiring the store to be committed before passing (the real
precondition -- an approved summary before the store's next commit -- is
gitlore's own gate, enforced at the moment it matters, not a
release-readiness verdict); relaxing the submodule rule in general (only
the memory store differs from HEAD between commits by design).

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
