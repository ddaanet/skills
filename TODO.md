## Open decisions

- Automatic description sync: should `just release` also copy each plugin.json `description` (and maybe `keywords`) into the matching `../claude-plugins/.claude-plugin/marketplace.json` entry? Today the recipe bumps only `version`, so descriptions drift on every wording change (a70fd8b was a hand sync).
- Marketplace README gaps: `sandbox-lies` and `ghmem` are listed in marketplace.json but have no README section, against the claude-plugins CLAUDE.md rule that the two stay in sync. Predates this work.
- onekeys: its default key map (onekeys 0.3.6, `scripts/onekeys-hook.sh`, shown at claude-plugins README.md:136) still binds `h` to `/handoff:handoff`; the fix belongs in the onekeys repo, via a brief in its `inbox/`.

## Remaining
