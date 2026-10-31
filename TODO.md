## Remaining

- Preflight: exclude the gitlore memory submodule from the clean-tree checks: `docs/plans/2026-08-13-preflight-memory-submodule.md`.
- Preflight: end on a release request in the user's own words: `docs/plans/2026-09-07-preflight-release-approval-provenance.md`. f27be16 already releases only when the request asked for one. Still missing: asking the user to state the bump, and the `!`-prefixed command fallback.
- After the next release: update the `ddaa-handoff` / `ddaa-passation` descriptions in `../claude-plugins/.claude-plugin/marketplace.json` to match their `plugin.json` (still "lightweight"/"léger"; `just release` bumps only versions). See `docs/plans/2026-09-20-handoff-plugin-is-not-lightweight.md`, Constraints.
