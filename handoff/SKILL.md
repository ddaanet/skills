---
name: handoff
description: >-
  Prepare a handoff summary to continue work in a new chat. Capture
  completed work, pending tasks, blockers, and learnings. Triggers on
  "/handoff", "handoff", "prepare a handoff", "summarize so I can continue
  tomorrow", "conversation too long", "let's pick this up in a new chat".
  Use when the user wants to transfer context to a future conversation.
---

# /handoff — Session Wrap-Up

Prepare a handoff document for continuing work in a new claude.ai
conversation. Context transfer, not documentation.

See `DESIGN.md` for design decisions.

## When to use /handoff vs /brief vs /tag

- `/handoff` — targets a future conversation. Full session summary of ongoing work
- `/brief` — targets Claude Code. Standalone mission document (the agent has no access to this conversation)
- `/tag` — targets a future conversation. Lightweight marker (the conversation is the content)

## Invocation

```
/handoff
```

Or in natural language: "prepare a handoff", "summarize so I can continue
tomorrow", "this conversation is getting long, let's start fresh".

## Protocol

### 1. Gather Context

Scan the conversation to identify:
- Completed work — results, deliverables, files produced
- Pending tasks — with enough context to act without re-reading
- Blockers and gotchas — root causes, not symptoms
- Decisions made — what and why (rationale)
- Learnings — patterns discovered, anti-patterns identified

### 2. Produce the Document

Generate a markdown file following the template in
**`references/template.md`**.

**Target: 75-150 lines of content.**
- Below 75: likely incomplete
- 75-150: good balance of detail and conciseness
- Above 150: check whether everything is necessary

### 3. Preserve Details That Save Time

**Include:**
- File paths, URLs, concrete references
- Decisions with rationale
- Rejected approaches and why (avoid rework)
- Metrics, numbers, specific data points
- Root causes of issues, not just symptoms

**Omit:**
- Step-by-step execution logs
- Obvious outcomes or confirmations
- Intermediate debugging that led nowhere
- Redundant information

### 4. Document Learnings

Format:

```markdown
## Learnings

**[Topic/Pattern]:**
- Discovery: [specific insight]
- Impact: [why it matters]
- Recommendation: [how to apply]
```

Focus on: technical discoveries, effective tool patterns, process
improvements, anti-patterns to avoid.

### 5. Present the Document

Present the file via `present_files`. The document should be ready to
paste into the first message of a new conversation.

End with a short note on the immediate next action.

## What the handoff does not do

- Does not produce a mission document for Claude Code (→ `/brief`)
- Does not place a conversation marker (→ `/tag`)
- Does not handle transmission — the user copies the document by their
  preferred method

## Resources

- **`references/template.md`** — Handoff document structure
- **`references/examples.md`** — Example handoff summaries
