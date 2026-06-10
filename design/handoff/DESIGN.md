# Passation / Handoff Skill — Design Decisions

## Provenance

Adapted from `agent-core` skill `/handoff` (session state persistence for
agent handoff). Original: the agent writes `agents/session.md` capturing
completed tasks, pending work, blockers, and learnings for the next agent
in the same worktree.

Adaptation for claude.ai: conversations have a natural end (context window,
topic shift, device change). The passation/handoff skill captures session
state so a new conversation can resume without re-explaining context.

## D-1: Two skills, distinct names (no suffix)

**Chosen:** `/passation` (FR) and `/handoff` (EN) as separate skills.

**Reason:** The French word "passation" and the English word "handoff" are
the natural terms in each language. Unlike "brief" (used as-is in French
professional contexts), these words are genuinely different — no suffix
needed to disambiguate.

This follows the i18n methodology grounded in MMLU-ProX (EMNLP 2025),
Cross-Lingual Prompt Steerability (Zhang et al., Dec 2025), and WMT 2025:
monolingual descriptions outperform cross-lingual ones for skill triggering.

See `brief-fr/DESIGN.md` D-1 for the full research basis.

**Maintenance:** Both skills share this DESIGN.md. Each version is a native
rewrite, not a mechanical translation. Reference files (template, examples)
are fully written in the skill's language.

## D-2: Conversion from agent-core, not porting

**Chosen:** Redesign for claude.ai constraints.

**Key differences from agent-core `/handoff`:**

| Aspect | agent-core | claude.ai |
|--------|-----------|-----------|
| Target | Next agent in same worktree | Human pasting into new conversation |
| Persistence | `agents/session.md` in git | Markdown artifact, copied manually |
| Task tracking | Structured `[ ]` with metadata, slugs, model tiers | Simple checklist |
| Learnings | Separate `agents/learnings.md` | Inline in handoff document |
| Carry-forward | Accumulated across handoffs, merge rules | Fresh each time |
| Continuation | Skill chaining via continuation protocol | None |

**Reason:** "Either do, or don't. Middle grounds are smelly." The agent-core
handoff is deeply integrated with worktree task lifecycle, plan directories,
and git state. Porting that machinery into claude.ai would create a skill
that references infrastructure that doesn't exist. The claude.ai version
keeps the purpose (context transfer) and discards the machinery.

## D-3: Relationship with /brief and /tag

**Chosen:** Clean separation, no coupling.

| Skill | Target | Nature | Produces |
|-------|--------|--------|----------|
| `/brief` | Claude Code agent | Mission document (scoped topic) | Markdown file |
| `/tag` | Future conversation | Position marker | Emoji + label in conversation |
| `/passation` | Future conversation | End-of-session summary | Structured handoff document |

The passation skill does not enumerate tags. Rationale: the passation skill
already reads the entire conversation to produce the handoff — tags add no
information that the conversation itself doesn't contain. Coupling the two
skills for marginal value (title suggestion) creates a dependency without
a proportional benefit.

## D-4: Output is a markdown artifact

**Chosen:** Markdown file via `present_files`.

**Reason:** The handoff document needs to be copyable into a new conversation's
first message. A file is more reliably extractable than inline conversation
text. The user can also paste it, AirDrop it, or store it.

## D-5: Length target 75-150 lines

**Chosen:** Soft guidance.

**Reason:** Below 75, the handoff is probably missing decision rationale or
pending task context. Above 150, it's probably retelling the conversation
instead of distilling it. This is guidance, not enforced — no validator
exists in claude.ai.

## D-6: No learnings.md separation

**Chosen:** Learnings inline in the handoff document.

**Reason:** In agent-core, learnings are separated because they accumulate
across sessions and feed into `/codify` for consolidation. In claude.ai,
there is no persistent `learnings.md` across conversations. Separating them
would create a file with no consumer. Inline keeps everything in one
copyable document.

## D-7: Notion-first delivery (amends D-4)

**Chosen:** When a Notion workspace is connected, the handoff is written as
a Notion page and the skill returns only a `[Title](url)` link. The
`present_files` artifact (D-4) becomes the fallback for claude.ai without
Notion.

**Reason:** This is what makes the skill useful in Claude Code: a hybrid
project where Claude Code cooperates with claude.ai stores its handoffs in
Notion, where a claude.ai conversation can pick them up. A local file or
`present_files` artifact has no consumer in that workflow. Provenance: the
"Correctifs passation" backlog in David's Notion workspace.

**Sub-decisions, all from that backlog:**

- **No double generation.** Once the handoff is on Notion, do not also emit
  a local file or `present_files` — Notion is the source of truth, and a
  second copy creates an ambiguous one. Return only the link.
- **Reverse-chrono positioning.** `notion-create-pages` appends to the end
  of the parent; the wanted order is most-recent-on-top. Reposition with
  `notion-update-page` command=`replace_content`, re-listing the parent's
  full set of `<page>` blocks with their one-line summaries. Surgically
  deleting a `<page>` block via `update_content` trashes the child page —
  this is the reliable pattern, learned the hard way in the candidature
  workflow. Both skills carry the warning so the lesson is not re-paid.
- **End-of-session triggers.** "fin"/"au revoir" (FR), "end"/"goodbye" (EN)
  fire the handoff without asking for confirmation — the user closing the
  session wants it cut cleanly, not a yes/no round-trip.
- **Current-session title.** After delivery, suggest the title of the
  session that is *ending* (so the user can find it in their claude.ai
  history), in a code block, with no prefix. Anti-pattern observed:
  suggesting the *next* conversation's title instead of the current one.

**Note:** A "post-candidature" trigger once filed here was reclassified to
the `/candidature` workflow — it is a candidature-side trigger that *calls*
handoff, not a mechanic of handoff itself.

**Note:** The Notion MCP workarounds (positioning, deletion pitfalls) are
expected to be purged if David migrates off the Notion MCP, as planned.
