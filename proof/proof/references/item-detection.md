# Item Detection

How to identify reviewable items. The core protocol is in SKILL.md —
this file provides detection and splitting rules.

## Automatic Detection

Parse artifact structure to identify items:

| Artifact type | Pattern | Granularity |
|--------------|---------|-------------|
| Structured document (headings) | `##`, `###` headings | Section |
| Paragraph-based text | Blank lines | Paragraph |
| Numbered / bulleted list | List entries | Entry |
| Multi-field form | One field = one item | Field |
| Source code | Function or class | Block |
| Diff output | Hunk markers (`@@`) | Hunk |
| Short message (<100 words) | Entire text | Single item |

**Fallback:** No structure detected → single item. Loop runs once.
Overview shows "1 item."

## Splitting Long Items

An item splits into sub-items when:

- **Independent concerns:** the item covers 2+ unrelated topics (working
  memory overload — Cowan 2001, ~4 concurrent items)
- **Visual context loss:** the item exceeds a screen of content
- **Internal structure:** sub-headings, sub-lists, or other natural
  decomposition markers

Present sub-items as "N.1/N.K", "N.2/N.K". Sub-items inherit the
parent's position in the linear order.

## Accumulation Format

Verdicts accumulate in memory during iteration. The list is the
structured input for batch-apply — the agent works from this list, not
from memory of the discussion.

```
- V-1: [identifier] — approve
- V-2: [identifier] — revise: "[user's stated fix]"
- V-3: [identifier] — delete
- V-4: [identifier] — skip
```

**Identifier:** item title or opening text. Must be unambiguous within
the artifact.

**Revise detail:** capture the user's fix as stated — this is the edit
spec for batch-apply. The discussion loop may refine the fix before the
verdict is recorded.

## Batch-Apply Execution

On user confirmation after the verdict summary:

- **approve** — no edit
- **revise** — apply the stated fix
- **delete** — remove the item
- **skip** — no edit (explicit deferral)

Apply bottom-to-top in the file to avoid line-shift interference. For
composite artifacts (multiple files), apply per-file independently.

## Revisit

After completing iteration, the user can revisit any previously-reviewed
item:

- Flexible identification: by number, title, or content description
- Semantic matching — no exact-match requirement
- New verdict replaces the old one in the accumulation list
- Returns to post-iteration state (not back into the linear sequence)
