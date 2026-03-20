---
name: brief-en
description: >-
  Produce a mission document for Claude Code. Extract decisions, constraints
  and conclusions from the current conversation. Triggers on "/brief",
  "brief for claude code", "prepare a brief", "transfer context to worktree".
  Use when design happens in claude.ai and execution in Claude Code.
---

# /brief-en — Mission Document for Claude Code

Produces a markdown file to hand off to a Claude Code agent. The brief exists
because the target agent cannot read claude.ai conversations — a real
isolation constraint.

See `DESIGN.md` for design decisions.

## When to use /brief vs /tag vs /handoff

- `/brief` — targets Claude Code. Produces a standalone document (the agent has no access to this conversation)
- `/tag` — targets a future conversation. Lightweight marker (the conversation is the content)
- `/handoff` — targets a future conversation. Overview summary to continue the work

## Invocation

```
/brief
/brief auth refactoring to OAuth2
```

Without a description, derive the subject from the current conversation and confirm.

## Process

### 1. Identify scope

Determine which conversation topics need briefing. If the conversation
covers multiple topics, ask or infer which one.

Do not brief the entire conversation — that is `/handoff`'s job.

### 2. Extract relevant context

Scan the conversation for the targeted subject. Extract:

- **Decisions made** — what and why (rationale)
- **Constraints identified** — technical, functional, temporal
- **Conclusions** — analysis results, consensus, trade-off resolutions
- **Scope changes** — additions, removals, deferrals
- **Approaches rejected** — and why (avoid rework)
- **Concrete references** — file names, URLs, code snippets, values

Do not include: discussion flow, intermediate attempts, social exchanges,
context the target agent can obtain by other means (existing docs, source code).

### 3. Produce the file

Generate a markdown file. Naming: `brief-<subject-kebab>.md`.

Structure:

```markdown
## Brief: <subject>

<date>

### Decisions

- ...

### Constraints

- ...

### Rejected approaches

- ...

### Additional context

<everything needed to act without access to this conversation>
```

Target length: 20-80 lines. Below that, likely incomplete.
Above that, check for unnecessary content or narration.

### 4. Present and orient

Present the file via `present_files`. Remind the destination:

> Brief ready. Place in `plans/<plan>/brief.md` or provide directly
> to the worktree agent.

## What the brief does not do

- Does not summarize the entire conversation (→ `/handoff`)
- Does not place a conversation marker (→ `/tag`)
- Does not handle transmission — the user copies the file by their
  preferred method (Desktop filesystem, manual copy, pasted into a prompt)
