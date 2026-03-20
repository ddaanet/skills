---
name: tag-en
description: >-
  Drop a searchable marker in the current conversation. The marker is a
  flag with a short agent-generated label — the content is the conversation
  itself, not the marker. Triggers on "/tag", "/tag followed by a
  description", "tag this", "mark this point", "bookmark this". Use when
  the user wants to make a moment in the conversation findable later.
---

# /tag — Conversation Marker

Drop a searchable flag in the current thread. The content is the
conversation; the tag is just the address.

See `DESIGN.md` for design decisions.

## When to use /tag vs /brief vs /handoff

- `/tag` — targets a future conversation. Lightweight marker (the conversation is the content)
- `/brief` — targets Claude Code. Standalone mission document
- `/handoff` — targets a future conversation. Full session summary to continue the work

## Invocation

Two forms:

```
/tag
```

The agent generates the label from the preceding context.

```
/tag data storage should not live in the local filesystem
```

Text after `/tag` provides context. The agent still generates a condensed
label — the user's text is not copied verbatim.

## What the tag produces

```
🏷️ data storage project memory architecture
```

An emoji flag followed by a few-word label. No date, no slug, no metadata.
The label serves as a search vector.

## Retrieval

From another chat, `conversation_search` finds the tag through the
label's keywords or the surrounding conversation context.

## What the tag does not do

- Does not summarize the discussion — the conversation is the content
- Does not duplicate the user's message
- Does not produce a file or artifact
- Does not replace the handoff
