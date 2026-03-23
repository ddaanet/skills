# Documentation Audit Guide

Detailed guidance for the documentation update step in preflight. Documentation
updates are batched at the end of the development cycle: hack, hack, hack,
preflight, release.

## Two Audiences

### Human-Facing (README.md)

The README is the project's public face. It must reflect craft.

**Style corpus:** Check for `tmp/STYLE_CORPUS` first (project-specific
samples). Then `STYLE_CORPUS.md` at the repo root. If neither exists, fall
back to `references/default-style-corpus.md`. Read the corpus before writing
to internalize the voice.

**Update process:**

1. Read style corpus to internalize conventions
2. Read current README.md
3. Identify stale sections by comparing against:
   - Commits since last tag (from step 5)
   - CLI commands: `<tool> --help` for each subcommand
   - Project structure: `src/` layout, test files
   - Dependencies: `pyproject.toml` / `package.json` / `Cargo.toml`
4. Rewrite stale sections applying style corpus conventions
5. Verify all code examples work (commands, flags, output)
6. Check internal consistency (features list matches usage sections)

**Common staleness patterns:**
- New CLI subcommands not documented
- Changed flags or arguments
- Outdated project structure trees
- Version requirements changed
- New dependencies undocumented
- Removed features still listed
- Example output doesn't match current behavior

**Style principles:**
- Lead with what the tool does, not implementation details
- Show real usage before explaining internals
- Keep code examples minimal and runnable
- Every section should earn its place

### Agent-Facing (if present)

Agent documentation targets LLMs and automation. Different quality bar:
precision, discoverability, structured triggers. Only audit these if the
project has them.

**Skill descriptions** (`skills/*/SKILL.md` frontmatter):
- Verify trigger phrases match actual usage
- Add triggers discovered during development
- Remove triggers for deprecated features

**CLAUDE.md and fragments:**
- Verify file references point to existing files
- Check behavioral rules match current implementation
- Confirm workflow descriptions are current

**Memory indices:**
- Verify entries point to existing files
- Check descriptions are keyword-rich for discovery
- No duplicate entries

**Skip agent doc updates** when nothing agent-related changed. Focus on
areas affected by actual changes.

## Diff-Driven Audit

Focus on what changed, not everything:

1. Get commits since last tag (already available from step 5)
2. Categorize: new features, changed APIs, removed features, infra
3. For each category, identify affected documentation sections
4. Update only affected sections

This prevents unnecessary churn in stable documentation.

## Commit Strategy

Documentation updates must be committed before the readiness report:

1. Complete all documentation updates
2. Stage documentation files
3. Commit with descriptive message
4. Proceed to readiness report (step 7)

The release recipe expects a clean working tree.
