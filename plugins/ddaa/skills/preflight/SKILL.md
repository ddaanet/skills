---
name: preflight
description: >-
  Validates git state, runs quality checks, audits documentation, and produces
  a go/no-go readiness report before releasing a package. Triggers on
  "preflight", "ready to release", "pre-release check", "release check",
  "prepare release", "check release readiness", or any mention of releasing
  a package. Use this skill before every release, even when it feels
  unnecessary -- that is precisely when it catches things.
---

# Preflight

Validate preconditions, audit documentation, and produce a readiness
assessment. Whether the release command then runs is a separate decision
-- see **After the report**.

Documentation updates are batched at the end of the development cycle:
hack, hack, hack, **preflight**, release.

## Step 1: Validate git state

Run in parallel:

```bash
git branch --show-current
git status --porcelain
git fetch --dry-run 2>&1
git log @{u}..HEAD --oneline 2>/dev/null
git submodule status 2>/dev/null
git config -f "$(git rev-parse --show-toplevel)/.gitmodules" \
  --get submodule.gitlore-memory.path 2>/dev/null
```

The last probe prints the path of the gitlore memory store, if the repo
mounts one. Empty output: no exemption, judge everything.

That one path is exempt from both clean-tree rules below while it is
merely modified: ` M`, `M ` or `MM` in `git status --porcelain`, `+` or
no prefix in `git submodule status`. The store differs from the parent's
HEAD between commits by design: gitlore commits it on its own and stages
its moved pointer, and the next parent commit records that pointer. Leave
those lines out and judge the rest as usual. Every other path still
counts, other submodules included.

A conflicted store is not exempt: an unmerged code (`UU`, `AA`, `DU` ...)
in porcelain or a `U` prefix in submodule status fails the clean tree,
and the fix is `/gitlore:resolve`.

Nor is a store checked out behind or beside its recorded pointer, which
also shows `+`: committing it would walk the pointer back. On `+`, run
`git -C <path> merge-base --is-ancestor "$(git rev-parse :<path>)" HEAD`
from the top level. Non-zero fails the clean tree; the fix is
`git submodule update -- <path>`, or `/gitlore:merge`.

The exemption only holds if the release recipe makes it too. When the
store is modified and the project's recipe refuses any dirty tree without
excluding that path, the release will refuse what preflight passed:
report a clean-tree FAIL whose fix is to exclude the path in the recipe.

| Check | Rule |
|-------|------|
| Branch | Must be `main`, `master` or `dev`. Abort otherwise. |
| Working tree | Must be clean, a modified memory store aside. Abort if dirty. |
| Remote sync | No unpushed/unpulled commits. Warn if diverged. |
| Submodules | No uncommitted changes, a modified memory store aside. Abort if dirty. |

## Step 2: Check for pending tasks

Look for pending task markers in common locations:

```bash
# Adapt to what exists in the project
for f in TODO.md agents/session.md TASKS.md; do
  [ -f "$f" ] && grep -c '^\- \[ \]' "$f" && echo "  ^ in $f"
done
```

Pending tasks are a warning, not a blocker. The human decides whether to
ship before completing them.

## Step 3: Run quality checks

Detect and run the project's check suite. Try in order:

```bash
just precommit 2>/dev/null \
  || just check 2>/dev/null \
  || make check 2>/dev/null \
  || npm test 2>/dev/null \
  || echo "NO_CHECK_FOUND"
```

If no check command is found, warn and continue. If checks fail, report
failures and abort. All checks must pass.

## Step 4: Update documentation

Read detailed guidance:

```
Read("references/documentation.md")
```

Two audiences:

**Human-facing (README.md):**
- Locate style corpus: `tmp/STYLE_CORPUS` > `STYLE_CORPUS.md` > bundled
  `references/default-style-corpus.md`
- Audit README against current project state (commits since last tag,
  CLI help output, directory structure, dependencies)
- Rewrite stale sections applying style conventions
- Verify all code examples work

**Agent-facing (only if present):**
- Skill descriptions (`skills/*/SKILL.md` frontmatter)
- `CLAUDE.md` and fragments: verify references point to existing files
- Memory indices: verify entries are current

Commit documentation changes before proceeding. The release recipe
expects a clean tree, the memory store aside: leave a modified store to
the commit that records its pointer, and do not commit inside it.

## Step 5: Assess release scope

Show what changed since the last release:

```bash
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -n "$latest_tag" ]; then
  git log "${latest_tag}..HEAD" --oneline
else
  echo "No tags found. Showing recent commits:"
  git log --oneline -20
fi
```

Summarize: number of commits, key changes grouped by category.

## Step 6: Detect version and release infrastructure

**Project type** -- check for:
- `pyproject.toml` (Python)
- `package.json` (Node.js)
- `Cargo.toml` (Rust)

**Current version** from the detected config file.

**Release command:**

```bash
just --list 2>/dev/null | grep -i release
```

If a `release` recipe exists, that is the release command. If not, note
its absence. Read the recipe for what it takes -- a bump level, an
explicit version, or nothing -- and for the flag that skips its
confirmation prompt, if it has one (`--yes`).

## Step 7: Readiness report

```
## Preflight Report

| Check               | Status |
|---------------------|--------|
| Branch              | pass/FAIL |
| Clean tree          | pass/FAIL |
| Remote sync         | pass/warn |
| Quality checks      | pass/FAIL/warn (no runner) |
| Pending tasks       | pass/warn (N pending) |
| Documentation       | pass/updated (N files) |

**Memory store:** `<path>` modified, left to the next commit

**Current version:** X.Y.Z
**Commits since last release:** N
**Key changes:**
- change summary 1
- change summary 2
```

Include the **Memory store** line only when Step 1 exempted a modified
store. It is information, neither a pass nor a failure.

If any FAIL: list each failure with specific fix instructions. Stop.

If all pass: confirm ready and continue with **After the report**.

## After the report

The release argument is what the release command takes: a bump level,
an explicit version, or nothing.

- FAIL checks: stop, wait for human to fix
- All pass, and the user's words asked for the release and gave its
  argument: report, then run the release command with that argument
- All pass otherwise: end the report by asking the user for the release
  argument -- or, when it takes none, to ask for the release -- then
  stop. Do not pick an argument, recommend one, or offer to proceed
- The reply gives it, even a bare `minor`: run the release command with it
- The reply does not (`ok`, `yes`), the release command is denied, or it
  cannot run here: print the exact command for the user to run -- in
  Claude Code prefixed with `!`, as in `! just release minor --yes` --
  and stop. Diagnose from its output once it lands. Never retry the
  command or run its steps one by one
- When the release command prompts for confirmation, pass its
  non-interactive flag, both when running it and in the printed command
- Do NOT invoke other skills

## Constraints

- **Never release on your own initiative.** Neither a passing report
  nor a yes to your own question is authorization, and neither is a
  request for something adjacent such as the readiness pass itself. Run
  the release command only when the user's own words asked for it --
  in the request, or in a reply giving the argument you asked for;
  otherwise ask for the argument, or print the command.
- **Abort on hard failures.** Branch, clean-tree, quality checks are
  blockers. Stop and enumerate fixes.
- **Warn on soft issues.** Pending tasks, missing check runner, remote
  divergence are warnings. Inform, do not block.
- **No version bumping.** This skill assesses readiness, it does not
  modify version numbers.
- **Same gate in every package.** Never add a project-specific check to
  this skill. Step 3 already runs whatever the project defines, so a
  project's own gate is reached through its check runner -- wire it into
  the project's `justfile`/CI, not here. Only universal checks (git
  state, doc audit, version infrastructure) belong in preflight.
- **No error suppression.** Never use `|| true` or swallow exit codes
  (exception: detection probes like `2>/dev/null` for optional tools).
- **Report failures clearly.** If anything fails, say what and stop.
