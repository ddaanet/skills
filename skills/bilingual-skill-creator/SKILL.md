---
name: bilingual-skill-creator
description: >-
  Create a skill in two languages (typically FR/EN). Wraps the i18n
  co-writing methodology around skill-creator. Triggers on "skill bilingue",
  "bilingual skill", "crée un skill en français et anglais", "create a
  skill in both languages", "i18n skill". Use whenever a skill must exist
  in more than one language. Do NOT use for monolingual skills — use
  skill-creator directly.
---

# Co-écriture bilingue de skills / Bilingual Skill Co-Writing

Wrap the i18n methodology around `/skill-creator`. This skill handles the
language dimension; skill-creator handles the craft dimension.

## Delegation

This skill does NOT replace skill-creator. It adds phases before and
between two skill-creator runs. For each language version:

1. Read `/skill-creator` SKILL.md (load it into context)
2. Follow skill-creator's process (draft → test → iterate → package)

The bilingual procedure below determines **what order** to do things and
**what to verify** between the two versions.

## Procedure

### Phase 0: Ground — linguistic anchoring

Before writing anything, search for current research on LLM performance
in the target language pair. Verify that the core hypothesis holds:
**native rewriting outperforms mechanical translation** for procedural/
instructional text (skill descriptions, triggers, templates).

Key references (as of March 2026):
- MMLU-ProX (EMNLP 2025) — cross-lingual performance degrades even
  between high-resource languages
- Cross-Lingual Prompt Steerability (Zhang et al., Dec 2025) —
  monolingual prompts reduce language-switching noise, +5-10% robustness
- WMT 2025 — LLM-based systems dominate document-level coherence
- Lokalise 2025 blind study — Claude excels at tone-sensitive translation

If the research landscape has shifted, adapt the methodology accordingly.

### Phase 1: Write the source version

Write the complete skill in whichever language is most natural for the
content and the author. Stabilize all design decisions, structure, and
boundaries before touching the second language.

Run skill-creator's full process on this version:
→ Load `/skill-creator` SKILL.md → draft → test → iterate → package

### Phase 2: Native rewrite of the target version

The second version is a **complete rewrite**, not a translation:
- Same design decisions, same section structure
- Phrasing must read naturally — a native speaker should not be able to
  tell it was derived from another language
- Triggers use the natural domain vocabulary in each language
- Examples are adapted to cultural context if needed

Run skill-creator's process on this version too:
→ Load `/skill-creator` SKILL.md → draft → test → iterate → package

### Phase 3: Structural alignment check

Verify section-by-section correspondence:
- Every section in the source exists in the target (and vice versa)
- Reference files (templates, examples) are fully in the skill's language
- DESIGN.md is shared between both versions (written in English)

### Phase 4: YAML description validation

The description is the trigger mechanism — most critical component:
- Must read naturally in the skill's language
- Must contain keywords the user would spontaneously use
- **Zero tokens from the other language** (cross-lingual contamination
  degrades triggering — measured by MMLU-ProX)
- Mental test: "if I type [typical phrase], does this description fire?"

## Naming Convention

Two cases:

**With suffix** (e.g. `brief-fr` / `brief-en`): when the trigger keyword
is the same word in both languages. The suffix disambiguates.

**Without suffix** (e.g. `passation` / `handoff`): when the trigger
keywords are naturally different. The name itself carries the language.

## Shared Files

- `DESIGN.md` — shared between both versions, written in English
  (architecture document, not user-facing)
- `references/*` — fully in the skill's own language, never shared

## What This Skill Does Not Cover

- Monolingual skills (use skill-creator directly)
- More than 2 languages (would need a selection/routing mechanism)
- Translation of user content (out of scope)

## Maintenance

`DESIGN.md` contains the grounding report for this methodology: research
sources, quality label, and adaptation rationale. Read it when updating
the Phase 0 references or questioning whether the core hypothesis still
holds.
