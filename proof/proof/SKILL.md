---
name: proof
description: >-
  Structured proofreading of text artifacts. Reviews each item with a
  forced verdict, accumulates decisions, applies as batch. Replaces
  "does this look right?" with item-by-item inspection. Triggers on
  "proof", "proofread", "review", "validate", "check my text", or when
  an artifact has just been generated and needs validation before
  sending. Use this skill for any text worth a careful read: letters,
  reports, documentation, messages, articles, specs.
---

# Proof — Structured Artifact Validation

Item-by-item review loop for text artifacts. Presents each discrete item,
analyzes it, waits for the user's reaction, classifies into an internal
verdict, accumulates decisions, applies as batch. Replaces single-turn
validation with an inspection that catches errors before they ship.

Grounded in Fagan inspection (per-item detection, reader-paraphrase,
forced verdict) and cognitive load research (chunking to ~4 concurrent
items — Cowan 2001).

## Artifact Source

The artifact under review can be:

- **A file** — local path or uploaded. Read contents before starting.
- **Text in the conversation** — the last generated text, or text pasted
  by the user. Treat as an in-memory artifact.

If the source is unclear, ask.

## Protocol

### 1. Overview

Before touching the first item, present:

- **Artifact:** what it is, who it's for, what channel (if known)
- **Items detected:** count, chosen granularity. See
  `references/item-detection.md` for splitting rules.
- **Review criteria:** which lenses are active for this review (tone,
  factual accuracy, structure, conciseness, audience fit — depends on
  artifact type)

Wait for the user's response before the first item. The user may:
reorder, skip sections, adjust scope, or proceed as-is.

**State line:**

```
[proof: overview <artifact> | decisions: 0]
```

### 2. Item-by-Item Iteration

Present each item in document order:

```
**Item N/M: [title or opening]**

[item content — plain text]

Analysis: [factual observations — problems found or confirmation that
the item is solid, with brief justification]
```

No verdict shortcuts displayed. The user reacts naturally: comments,
approves, corrects, asks for removal, or moves on. The agent infers the
verdict from the response (see §Verdict Model).

**Analysis:** Evaluate against the active review criteria. Flag concrete
problems. If nothing to flag, say why it holds up — not just "looks good."
The analysis helps the user decide; it doesn't decide for them.

**State line after each inferred verdict:**

```
[proof: item N/M | decisions: K]
```

### 3. Discussion

If the user's response doesn't map directly to a verdict:

1. **Restate:** "I understand: [restatement]. Right?" Wait for
   confirmation.
2. **Accumulate:** Each confirmed point adds to the decision list for
   this item.
3. **Converge toward a verdict** when the discussion resolves.

### 4. Mid-Iteration Actions

Available at any point, don't interrupt the loop:

- **"status"** or **"sync"** — display all accumulated decisions
- **"revisit N"** — change the verdict of an already-reviewed item
  (by number, title, or content). New verdict replaces old. Returns to
  current position.

### 5. End of Loop

When all items are done, or at the user's request ("let's wrap up",
"apply"):

**Verdict summary:**

```
N approved, N revised, N deleted, N skipped
```

Then ask for confirmation before applying.

### 6. Batch Apply

Apply all decisions at once:

- **If the artifact is a file:** edit the file (str_replace or
  Filesystem:edit_file), applying corrections bottom-to-top to avoid
  line-shift interference.
- **If the artifact is conversation text:** produce the corrected version
  as a downloadable file (present_files).

**Application order:** bottom-to-top in the document so line numbers
remain valid.

### 7. Verification

After applying, re-read the result to verify:

- Corrections are applied faithfully
- No new errors introduced by the edits
- Overall coherence is preserved
- **Cross-item coherence:** corrections to separate items don't create
  redundancy, contradiction, or tone breaks between them. Item-by-item
  iteration creates a blind spot for inter-item interactions —
  verification is where you compensate.

If a problem is found, flag it to the user with a proposed fix. Never
edit silently.

## Verdict Model (internal)

The user never sees these categories or any shortcuts. The agent
classifies each response into one of 4 verdicts:

| Verdict | The user typically says |
|---------|----------------------|
| **approve** | "ok", "fine", "nothing to change", "next", "looks good", implicit agreement |
| **revise** | gives a correction, rephrases, says "change X to Y", "more like this", "I'd prefer…" |
| **delete** | "remove this", "cut it", "unnecessary", "drop this part" |
| **skip** | "not sure, move on", "come back to it later", "skip" |

**Classification rules:**

- When in doubt between approve and skip → **skip** (conservative).
- When in doubt between revise and delete → **ask** ("do you want to
  rephrase or remove entirely?").
- A response that mixes a comment with approval ("ok but maybe I'd…")
  → **discussion**, not a verdict.
- No explicit reaction to an item is never a verdict. If the user moves
  on without addressing an item, remind them.

**Internal accumulation format:**

```
- V-1: [identifier] — approve
- V-2: [identifier] — revise: "[user's stated fix]"
- V-3: [identifier] — delete
- V-4: [identifier] — skip
```

## Anti-Patterns

- **Single-turn validation:** "Does this look right?" → "yes" → ship.
  No restatement, no accumulation. Misses misunderstandings.
- **Inline edits:** Editing the file during iteration instead of
  accumulating. Loses track of decisions, breaks batch-apply atomicity.
- **Silent advancement:** Moving past an item without an inferred verdict.
  Every item gets a disposition — if the user doesn't address it, remind
  them.
- **Exposing shortcuts:** Never display (a/r/d/s) or internal verdict
  names. The user speaks naturally, the agent classifies internally.
- **Empty analysis:** "This item looks fine." with no justification. If
  it's fine, say why in one sentence.
- **Random-access navigation:** Jumping to an arbitrary item during
  iteration. Linear presentation only; "revisit" is post-completion.
