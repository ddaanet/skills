## Brief: carve the memory submodule out of preflight's clean-tree checks

2026-08-13

Proposal from the gitlore repo. `ddaa:preflight` is currently unpassable in
any repo whose memory is a gitlore submodule.

### The problem

`plugins/ddaa/skills/preflight/SKILL.md` Step 1 aborts on two rules:

| Working tree | Must be clean. Abort if dirty. |
| Submodules | No uncommitted changes. Abort if dirty. |

In a gitlore repo, ` M memory` in the parent's `git status --porcelain` is
the **resting state**, not an incomplete working tree. Nobody commits inside
the memory store: the parent's pre-commit hook records it, gates it, and
stages the moved gitlink into whatever parent commit comes next. The dirty
state is what the design produces on purpose and it clears as a side effect
of the next parent commit.

So preflight aborts, and the only way past it is to perform by hand the
commit the release was going to make anyway.

### Decisions

- The carve-out covers **exactly one path** — the gitlore memory submodule.
  Untracked and modified files elsewhere in the parent stay genuine
  findings. A gate that waves those through is broken in the other
  direction.
- The excluded path is reported as **information**, not silently dropped and
  not counted as a pass.
- Detect the path, do not hardcode `memory`. The submodule is registered
  under a stable name, so:

  ```sh
  git config -f .gitmodules --get submodule.gitlore-memory.path
  ```

  Verified consistent across eleven repos that mount gitlore. Empty output
  means the repo has no gitlore store and current behaviour applies
  unchanged.
- Both language variants move together:
  `plugins/ddaa/skills/preflight/SKILL.md` and
  `plugins/ddaa-fr/skills/preflight/SKILL.md`.

### Rejected approaches

- **Checking that the memory store is committed before passing.** The one
  real precondition dirty memory carries is a fresh approved summary before
  the next parent commit — written after the last memory edit, since the
  gate compares mtimes. That is a commit-time requirement enforced by
  gitlore's own pre-commit hook, which blocks and says so. It is not a
  release-readiness verdict, and duplicating it in preflight would only
  reproduce a check that already fires at the right moment.
- **Relaxing the submodule rule generally.** Other submodules with
  uncommitted changes are still a real finding; only the memory store has a
  design that guarantees it is dirty between commits.

### Additional context

gitlore (https://github.com/ddaanet/gitlore) makes Claude Code's auto-memory
a git submodule at `memory/`, committed by the parent's pre-commit hook and
pushed alongside the parent. Facts get written throughout a session and the
store stays dirty until the next parent commit sweeps it in — which is the
same commit a release would produce.

This brief is a proposal only. The gitlore session that found it treats
other repos as read-only.
