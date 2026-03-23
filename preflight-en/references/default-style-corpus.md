# Default Style Corpus

Fallback style reference when the project has no `tmp/STYLE_CORPUS` or
`STYLE_CORPUS.md`. Demonstrates the voice and structure for technical READMEs.

---

## Voice: Direct, Confident, Useful

Write like a skilled engineer explaining their tool to a peer. No marketing
language, no hedging, no filler.

**Good:**
> Extract user feedback from conversation history. Supports recursive
> sub-agent traversal, noise filtering, and structured JSON output.

**Bad:**
> This amazing tool helps you easily extract valuable feedback from your
> conversations! It's designed to be simple and powerful.

---

## Structure: What, How, Details

Order sections by what the reader needs first:

1. **What it does** -- one sentence, what problem does it solve?
2. **Installation** -- fastest path to working setup
3. **Usage** -- real commands with real output, common operations first
4. **Features** -- bullet list of capabilities (scannable)
5. **Configuration** -- options, environment variables, settings
6. **Development** -- for contributors: build, test, lint
7. **Architecture** -- for deep divers: design decisions, module structure

Skip sections that add no value. A three-section README that's complete
beats a ten-section README with filler.

---

## Code Examples: Real, Minimal, Runnable

Every code example should work if copy-pasted. Show concrete values, not
angle-bracket placeholders. Show 2-3 examples covering common cases. Add
a comment only when the command isn't self-evident.

---

## Technical Accuracy

- Every command must reflect the actual CLI interface
- Every flag must be real and current
- Project structure trees must match the filesystem
- Version requirements must match the config file
- Dependency lists must be current

Stale documentation is worse than no documentation.

---

## Tone

| Context | Tone |
|---------|------|
| Usage examples | Minimal, practical |
| Feature descriptions | Confident, specific |
| Architecture notes | Technical, precise |
| Error messages | Clear, actionable |
| Warnings | Direct, no hedging |

Never apologize, hedge, or pad. State facts. Give instructions. Move on.
