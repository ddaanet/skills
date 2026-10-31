## Brief: the `handoff` plugin is now `autodrive-handoff`

2026-10-31, from autodrive-handoff. A proposal, not a decision. It adds to
`inbox/brief-handoff-plugin-is-not-lightweight.md` (2026-09-20), which asks to
drop "lightweight" and "léger". This one is about the name.

### Decisions

- None taken here. The rename is decided and shipped upstream. How this
  repository words it is its own call.

### Constraints

- The plugin is `autodrive-handoff`, and its skill is
  `/autodrive-handoff:handoff`. The ddaanet marketplace
  (`claude-plugins/.claude-plugin/marketplace.json`) lists it at 0.19.0 with
  `"renames": {"handoff": "autodrive-handoff"}`. The repository is
  `github.com/ddaanet/autodrive-handoff`.
- The "enable one, not both" advice still has its reason. Both plugins ship
  a skill named `handoff`, and their trigger phrases overlap: "/handoff",
  "handoff", "save handoff", "save context", "prepare handoff".

### Rejected approaches

- None.

### Additional context

Places that name the plugin by its old name:

- `plugins/ddaa-handoff/.claude-plugin/plugin.json:4`: "Enable this OR the
  lightweight handoff plugin, not both."
- `plugins/ddaa-passation/.claude-plugin/plugin.json:4`: "Activer celui-ci OU
  le plugin handoff léger, pas les deux."
- `README.md:31`: "the lightweight `handoff`".

Proposal:

- Name it `autodrive-handoff` in those three places. Fold in the wording fix
  from the 2026-09-20 brief in the same pass, since both touch the same
  sentences.
