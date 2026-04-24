# DESIGN — relecture / proof

Shared design document for the bilingual skill pair `relecture` (FR) /
`proof` (EN). Written in English (architecture document, not user-facing).

## Lineage

```
agent-core/skills/proof (Claude Code, pipeline)
  → relecture/proof (claude.ai, standalone)
```

The agent-core version is a pipeline component invoked by hosting skills
(/design, /runbook, /requirements) with sub-agent dispatch, planstate
lifecycle, and recall-artifact integration. This version is a standalone
skill for claude.ai — no pipeline, no sub-agents, no lifecycle files.

## Adaptation Decisions

### Removed (pipeline-specific)

| Element | Reason |
|---------|--------|
| Task tool / corrector dispatch | No sub-agents in claude.ai |
| Planstate lifecycle (`plans/<job>/lifecycle.md`) | Pipeline-specific |
| Recall-artifacts (`claudeutils _recall resolve`) | Pipeline-specific |
| Author-Corrector Coupling (T1-T6.5) | Pipeline-specific |
| Layered Defect Model | Pipeline-specific |
| Integration Points (5 hosting skills) | Pipeline-specific |
| Glob/Grep/Bash for exploration | Not universally available |
| Cross-item outputs (learn/pending/brief) | Pipeline-specific |
| Kill + absorb | Simplified to delete only — absorb across artifacts is rare outside pipeline |

### Retained (core protocol)

| Element | Adaptation |
|---------|-----------|
| Item-by-item loop (Fagan) | Identical |
| Overview (summary + item list) | Condensed, one-phrase style |
| Verdicts (approve/revise/delete/skip) | Internal model only — not exposed as shortcuts |
| Discussion sub-loop + restatement | Identical |
| Accumulation + batch-apply | Identical |
| Sync (display decisions) | Identical |
| Revisit | Identical |
| Item splitting (item-review.md) | Simplified — no agent-core-specific patterns |
| State line | Simplified: `[relecture: item 3/7 \| decisions: 2]` |
| Anti-patterns | Adapted + one added (exposing shortcuts) |

### Added

| Element | Rationale |
|---------|-----------|
| Conversational verdict inference | D-3 from candidature DESIGN: user speaks naturally, agent classifies internally. Target audience is not CLI users. |
| Text-in-conversation source | Agent-core assumed file paths. claude.ai users paste text. |
| Auto-verification (§7) | Replaces corrector dispatch. Agent re-reads after batch-apply. |
| Cross-item coherence check | Discovered during test: item-by-item iteration creates blind spot for inter-item interactions. Verification compensates. |

## Theoretical Foundations

### Fagan Inspection (Fagan 1976)

Structured review process for detecting defects in documents. Key
principles retained:

- Per-item detection (not holistic impression)
- Reader-paraphrase (restatement forces understanding)
- Forced verdict (no silent advancement)
- Batch correction (rework is separate from detection)

Reference: Fagan, M.E. (1976). "Design and code inspections to reduce
errors in program development." *IBM Systems Journal*, 15(3), 182–211.

### Cognitive Load — Chunking (Cowan 2001)

Working memory holds ~4 items simultaneously. Item-by-item presentation
with forced verdict prevents overload. Long items auto-split when they
exceed this capacity.

Reference: Cowan, N. (2001). "The magical number 4 in short-term memory:
A reconsideration of mental storage capacity." *Behavioral and Brain
Sciences*, 24(1), 87–114.

### Conversational Interface (D-3, candidature DESIGN)

Verdict shortcuts (a/r/k/s) are a barrier for non-technical users. The
agent infers verdicts from natural language. Internal model maps typical
phrases to verdict categories. Ambiguity rules favor conservative
classification (skip over approve, ask over assume).

Origin: Decision D-3 in `ddaanet/candidature` DESIGN.md, validated
during Dailymotion application session (March 2026).

## Anti-Patterns

- **Exposing internal vocabulary:** verdict shortcuts, state machine
  terms, protocol jargon. The user sees a conversation, not a protocol.
- **Single-turn validation:** skipping the loop entirely. The whole point
  of the skill is forced per-item attention.
- **Inline edits:** breaking atomicity by editing during iteration.
- **Empty analysis:** "looks good" without justification erodes trust in
  the review.

## Grounding Audit

| Claim | Source | Status |
|-------|--------|--------|
| Fagan inspection improves defect detection | Fagan 1976, replicated by IBM, HP | Verified |
| Working memory ~4 items | Cowan 2001 | Verified |
| Native rewrite > mechanical translation for procedural text | MMLU-ProX (EMNLP 2025), Cross-Lingual Prompt Steerability (Zhang et al. Dec 2025) | Verified — see bilingual-skill-creator DESIGN.md |
| Conversational verdict inference preferred by non-technical users | candidature D-3, qualitative observation | Low-N, design decision |

## Naming

`relecture` / `proof` — trigger keywords are naturally different in each
language. No suffix needed (unlike `brief-fr` / `brief-en` where the
keyword is the same word).
