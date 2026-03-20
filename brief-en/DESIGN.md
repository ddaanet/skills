# Brief Skill — Design Decisions

## Provenance

Adapted from `agent-core` skill `/brief` (cross-worktree context transfer).
Original: worktree agent writes `plans/<plan>/brief.md` to transfer scope
changes, decisions, and conclusions from a parent conversation to a child
worktree.

Adaptation for claude.ai/Desktop: discussion happens in claude.ai, execution
happens in Claude Code. The isolation constraint is real — Claude Code agents
cannot read claude.ai conversations. The brief is the bridge.

## D-1: Two skills, not one with i18n

**Chosen:** `/brief-fr` and `/brief-en` as separate skills.

**Reason:** The skill description is the trigger mechanism — it is always
in context and Claude matches it against the user's message to decide
activation. Research (MMLU-ProX 2025, "Beyond English" 2025, "Lost in
the Mix" 2025) shows:

- Matching prompt language to interaction language outperforms cross-lingual
- Embedding non-target tokens into a prompt consistently degrades performance
- Automated translation of prompts drops below 50% accuracy

The Agent Skills standard (agentskills.io) provides no multilingual
description field. The description is displayed in UI before triggering —
it must read naturally in the user's language.

**Rejected:** Single skill with bilingual description crammed into 200 chars.
Single skill with body-only i18n (description still mismatches). Automatic
translation at install time (worst option per research).

**Maintenance:** The two skills share the same DESIGN.md. The English
version is a native rewrite, not a mechanical translation — written by
Claude as a design assistant, following the same anchoring research.

## D-2: Brief vs tag vs passation — clean separation

**Chosen:** Three distinct skills, no overlap.

| Skill | Target | Nature | Produces |
|-------|--------|--------|----------|
| `/brief` | Claude Code agent | Mission document | Markdown file |
| `/tag` | Future conversation | Position marker | Emoji + label in conversation |
| `/passation` | Future conversation | End-of-session summary | Structured handoff document |

**Reason:** "Either do, or don't. Middle grounds are smelly." Each skill
has exactly one purpose and one target. The brief was initially designed
as a conversation-embedded summary (middle ground) — iterative reduction
showed the conversation itself serves that role via `conversation_search`.
The brief only has value when the target cannot access the conversation
(Claude Code isolation).

**Key insight:** In the original agent-core architecture, briefs exist
because worktrees are isolated. In claude.ai, `conversation_search` gives
cross-conversation access — so the brief-as-note is redundant. Only the
Claude Code target restores the original justification.

## D-3: Output is a file, not conversation text

**Chosen:** Markdown file via `present_files`, not inline conversation text.

**Reason:** The brief crosses an environment boundary (claude.ai → Claude Code).
It needs to be downloadable, copyable to a filesystem path, or pasteable
into a Claude Code prompt. An inline message can't be reliably extracted.

**Convention:** `brief-<subject-kebab>.md`. Matches agent-core convention
where briefs live in `plans/<plan>/brief.md`.

## D-4: Extraction rules

**From `workflow-advanced.md` — "when adding entries without documentation":**
Index entries must point somewhere. Analogously, brief items must be
actionable — every decision or constraint in the brief must give the
target agent enough context to act without asking.

**From `workflow-advanced.md` — "when converting external documentation":**
Two trigger classes with different automation profiles. Similarly, brief
content has two profiles:
- Decisions/constraints — factual, extractable mechanically from conversation
- Rationale/context — requires judgment about what the target agent needs

**From `implementation-notes.md` — "when placing DO NOT rules":**
Exclusion rules ("do not include discussion flow") are co-located with
inclusion rules ("extract decisions, constraints, conclusions") in the
same process step.

## D-5: Length target 20-80 lines

**Chosen:** Hard guidance, not enforced.

**Reason:** Below 20, the brief is probably just listing decisions without
rationale — the target agent can't evaluate applicability. Above 80,
the brief is probably retelling the conversation — it's become a handoff
in disguise.

**From `implementation-notes.md` — "when choosing hard or soft limits":**
The principle says "either fail build or don't check." Here we can't
fail build (no validator), so it's guidance. If this skill is ported to
Claude Code with a validator, the 80-line ceiling should become a hard error.

## D-6: No transmission responsibility

**Chosen:** The skill produces the file. The user transmits it.

**Reason:** Transmission paths vary (Desktop filesystem tools, manual copy,
paste into prompt, `git show` from a shared repo). The skill can't know
which path the user will take. Mixing production and transmission creates
a middle ground — the skill would need to ask about the destination,
adding ceremony without value.

**From `operational-tooling.md` — "when workaround requires creating
dependencies":** If solving transmission means adding steps, stop and
let the user handle it.

## D-7: Naming follows discoverability

**From `operational-tooling.md` — "when choosing name":**
"/brief" is the word users think of when they need this capability.
Alternative candidates considered: `/transfert`, `/ctx`, `/passe`.
All score lower on recall — "brief" is used in both French and English
professional contexts.

The `-fr`/`-en` suffix is a concession to the i18n constraint. The user
installs the one matching their interaction language. If the platform
later supports multilingual descriptions, the suffix becomes unnecessary.
