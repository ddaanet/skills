---
name: preflight-en
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
assessment. The actual release command is human-executed.

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
```

| Check | Rule |
|-------|------|
| Branch | Must be `main` or `master`. Abort otherwise. |
| Working tree | Must be clean. Abort if dirty. |
| Remote sync | No unpushed/unpulled commits. Warn if diverged. |
| Submodules | No uncommitted changes. Abort if dirty. |

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
expects a clean tree.

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
its absence.

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

**Current version:** X.Y.Z
**Commits since last release:** N
**Key changes:**
- change summary 1
- change summary 2

**Release command:**
  `just release`           # patch bump (default)
  `just release minor`     # minor bump
  `just release major`     # major bump
```

If any FAIL: list each failure with specific fix instructions. Stop.

If all pass: confirm ready and show the release command.

## After the report

- FAIL checks: stop, wait for human to fix
- All pass: skill completes, no further action
- Do NOT invoke other skills or commands
- Human executes release command manually

## Constraints

- **Never run the release command.** Human-only.
- **Abort on hard failures.** Branch, clean-tree, quality checks are
  blockers. Stop and enumerate fixes.
- **Warn on soft issues.** Pending tasks, missing check runner, remote
  divergence are warnings. Inform, do not block.
- **No version bumping.** This skill assesses readiness, it does not
  modify version numbers.
- **No error suppression.** Never use `|| true` or swallow exit codes
  (exception: detection probes like `2>/dev/null` for optional tools).
- **Report failures clearly.** If anything fails, say what and stop.
