---
name: handoff
description: >-
  Prepare a handoff summary to continue work in a new chat. Capture
  completed work, pending tasks, blockers, and learnings; deliver to Notion
  (link only) when it's available. Triggers on "/handoff", "handoff", "save
  handoff", "save context", "prepare handoff", "write handoff", "before
  /clear", "before I clear", "clear handoff", "discard handoff", "clean
  handoff", "finalize", "wrap up", "I'm done", "summarize so I can continue
  tomorrow", "conversation too long", "let's pick this up in a new chat",
  "end", "goodbye". Use when the user wants to transfer context to a future
  conversation or close the session cleanly.
---

# /handoff — Session Wrap-Up

Prepare a handoff document for continuing work in a new conversation.
Context transfer, not documentation.

See `README.md` for design decisions.

## When to use /handoff vs /brief

- `/handoff` — targets a future conversation. Full session summary of ongoing work
- `/brief` — targets Claude Code. Standalone mission document (the agent has no access to this conversation)

## Triggering

- **Explicit:** `/handoff`, "prepare a handoff", "summarize so I can
  continue tomorrow", "this conversation is getting long, let's start fresh".
- **End of session:** "end", "goodbye". The user wants to close the session
  cleanly — produce the handoff without asking for confirmation.

## Protocol

### 1. Gather Context

Scan the conversation to identify:
- Completed work — results, deliverables, files produced
- Pending tasks — with enough context to act without re-reading
- Blockers and gotchas — root causes, not symptoms
- Decisions made — what and why (rationale)
- Learnings — patterns discovered, anti-patterns identified

### 2. Produce the Content

Generate the content in markdown following the template in
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

### 5. Deliver the Handoff

Two paths, depending on the environment.

**To Notion (hybrid project, or claude.ai with Notion connected) — preferred path:**

1. Create the page under the relevant parent — the project or area page the
   conversation concerns — with `notion-create-pages`. If the parent is
   ambiguous, ask.
2. **Reposition to the top.** `notion-create-pages` always appends the page
   to the end of the parent's list; the wanted order is reverse-chrono
   (most recent on top). Reposition via `notion-update-page`
   command=`replace_content`: re-list the parent's entire set of
   `<page url="…">` blocks in the wanted order, the new one first, each with
   its one-line summary next to the reference. Do **not** delete an isolated
   `<page>` block via `update_content` — that sends it to the trash (pitfall
   documented in the candidature corrections).
3. **No double generation.** Do not regenerate the content as a local file
   nor use `present_files`. Produce only a `[Title](url)` link to the Notion
   page. Same rule for any document already saved to Notion: Notion is the
   source of truth.

**Without Notion (claude.ai only):**

Present the file via `present_files`. The document should be ready to paste
into the first message of a new conversation.

### 6. Show the Current Session Title

After delivery, suggest a title for **the session that is ending** — not the
next one — so it can be found in the claude.ai history. Put it in a code
block, with no "title" word or prefix ("title:"), just the text:

```
Payment API integration — OAuth2 auth in place
```

Anti-pattern: showing the title of the *next* conversation. The title
describes what happened in *this* session, not what comes next.

End with a short note on the immediate next action.

## What the handoff does not do

- Does not produce a mission document for Claude Code (→ `/brief`)
- Does not handle transmission — the user opens the Notion page or copies
  the document by their preferred method

## Resources

- **`references/template.md`** — Handoff document structure
- **`references/examples.md`** — Example handoff summaries
