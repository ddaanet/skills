# Tag Skill — Design Decisions

## Provenance

No direct agent-core equivalent. The tag skill emerged during the
conversion of `/brief` from agent-core to claude.ai: iterative design
revealed that a full brief was redundant inside claude.ai because
`conversation_search` provides cross-conversation access. The tag
captures what a brief was reduced to — a searchable position marker
with no content duplication.

## D-1: Two skills with suffix (tag-fr / tag-en)

**Chosen:** `/tag-fr` and `/tag-en` as separate skills.

**Reason:** "tag" is the same word in French and English technical
vocabulary. Unlike passation/handoff (naturally distinct words), the
trigger keyword is identical — so the suffix is needed to disambiguate.

Follows the brief-fr/brief-en model. See `brief-fr/DESIGN.md` D-1 for
the full i18n research basis.

## D-2: The conversation is the content

**Chosen:** The tag produces only an emoji flag with a short label. No
summary, no metadata, no structured output.

**Reason:** In claude.ai, `conversation_search` retrieves conversations
by keyword matching against conversation content. A tag is a search
anchor — it amplifies retrievability of a specific moment by injecting
concentrated keywords. The conversation itself already contains all the
context.

**Key insight:** Tags are addresses, not documents. The value is
findability, not information.

## D-3: Agent-generated labels

**Chosen:** The agent generates the label, even when the user provides
descriptive text after `/tag`.

**Reason:** The user's text provides context, but the label should be a
condensed search vector — a few words optimized for later retrieval. The
user writes "le stockage des données ne devrait pas être dans le
filesystem local" and the agent produces `🏷️ stockage données mémoire
projet`. The condensation is the skill's job.

## D-4: No coupling with passation/handoff

**Chosen:** Tags are standalone. They do not feed into passation/handoff
title generation or enumeration.

**Reason:** The passation skill reads the entire conversation to produce
a handoff document. It doesn't need an intermediate index of tags to
understand the conversation's topics. Coupling tag to passation would
create a dependency (tag must know passation exists, passation must parse
`🏷️` markers) for marginal value (title suggestion). "Either do, or
don't. Middle grounds are smelly."

**Previous design:** Tag skill v1 included an "Énumération" section
describing how tags could be listed to feed passation title generation.
Removed because the coupling cost exceeded the benefit.

## D-5: No file output

**Chosen:** Tag produces inline conversation text only.

**Reason:** The tag is a marker *within* the conversation. A file would
separate it from the content it marks. The tag must live where
`conversation_search` can find it — in the conversation flow itself.
