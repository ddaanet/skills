## Brief: preflight must not end on an agent-authored release proposal

2026-09-07

Correction to the `ddaa:preflight` skill, found while running a
release-readiness pass in `claude-plugin-dev` and then cutting the release.

### Decisions

- **Preflight's terminal step must produce a release request in the user's own
  words, or hand the user a runnable command.** Ending the readiness report
  with the agent proposing the release and accepting a terse confirmation
  leaves the agent unable to run it.
- Where the skill cannot get that, it should print the release command for the
  user to run themselves — in Claude Code, prefixed with `!` so the output
  lands in the conversation and the agent can diagnose from it.

### Constraints

- The Claude Code auto-mode classifier gates an outward-facing command on
  whether **a user prompt requested that action**, not on the command string.
  A release recipe is not categorically blocked.
- A bare `ok` answering a question the agent itself authored does not carry the
  request. Neither does an opening prompt that asked for something adjacent —
  here it asked for a memory push and a readiness pass, and the readiness pass
  is precisely what precedes a release.
- This bites preflight harder than most skills: its whole purpose is to end
  immediately before a release, so the approval it collects is the one the
  classifier will look for and not find.

### Observed

Session opened with `run /gitlore:push, then the release-readiness pass
described in the task file`. After the pass reported green, the agent asked
whether to cut `patch` or `minor` and offered to proceed. The user replied
`ok`. `just release patch` was then denied:

```
Permission for this action was denied by the Claude Code auto mode classifier.
Reason: Blocked by classifier.
```

Nothing had executed at that point — no commit, no tag, no push. The user ran
the same recipe themselves and it completed normally, all steps landing.

### Rejected approaches

- **Decomposing the release into individual `git` / `gh` steps to route around
  the denial.** A release recipe is one atomic sequence; running its parts by
  hand is how a release ends up half-landed — version commit and tag public,
  dist tag or GitHub release missing. That is the exact state the resume
  machinery exists to repair, so manufacturing it to dodge a permission gate
  trades a clean stop for a dirty one.
- **Re-asking the user to confirm.** A second agent-authored question has the
  same provenance problem as the first.

### Additional context

- Suggested shape for the fix: preflight's closing section asks the user to
  state the release itself ("reply with the bump you want cut"), so their
  answer names the action; and its fallback prints the exact command with a
  `!` prefix rather than the agent retrying.
- Separate, previously recorded issue with the same skill, not addressed here:
  preflight aborts on a dirty tree when the only dirty path is a gitlore memory
  submodule (` M memory`), which is that design's resting state between
  commits. See the ddaanet memory `preflight-excludes-memory-submodule`.
