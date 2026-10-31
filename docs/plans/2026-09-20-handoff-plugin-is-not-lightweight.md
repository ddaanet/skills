## Brief: stop calling the `handoff` plugin "lightweight"

2026-09-20

Wording correction, found while rewriting the `ddaanet/claude-plugins`
marketplace README from each plugin's own README. The marketplace README has
already been fixed (commit `📝 rewrite README as per-plugin sections from
plugin READMEs`); this repo is the source the wording came from.

### Decisions

- **Drop "lightweight" / "léger" wherever this repo describes the `handoff`
  plugin.** The user's verdict: that plugin is anything but lightweight. It
  now ships five skills (`handoff`, `precompact`, `autoname`, `restart`,
  `pending`), several hooks, tmux-driven `/clear` / `/compact` / `/exit`
  transitions, and needs `python3` and `jq`.
- **Say what actually distinguishes the two providers instead of sizing
  them.** The contrast that holds is *what crosses the boundary*: `handoff`
  keeps a local task snapshot (current task, open decisions, remaining
  todos) re-injected verbatim at session start; `ddaa-handoff` /
  `ddaa-passation` write a full end-of-session summary, delivered to Notion
  when available. The marketplace README settled on: "the `handoff` plugin —
  a local task snapshot rather than a full session summary — covers the same
  ground."
- Keep the "enable one or the other, not both" rule. Only the adjective goes.

### Known occurrences

- `README.md` line 31 (EN): "the lightweight `handoff` plugin covers the same
  ground".
- `README.md` line 134 (FR): "le plugin `handoff` léger couvre le même
  besoin".
- `plugins/ddaa-handoff/.claude-plugin/plugin.json` `description`: "Enable
  this OR the lightweight handoff plugin, not both."
- `plugins/ddaa-passation/.claude-plugin/plugin.json` `description`: "Activer
  celui-ci OU le plugin handoff léger, pas les deux."

Grep for `lightweight`, `léger` and `leger` across the repo — skill bodies
and `design/*/DESIGN.md` were not checked.

### Constraints

- FR text is a native rewrite, not a translation of the EN fix. Reword the
  French sentence on its own terms.
- A `plugin.json` description change only reaches users after a **version
  bump**: same version = update skipped. All four plugins are at 0.5.0.
- The marketplace (`../claude-plugins/.claude-plugin/marketplace.json`)
  copies the `ddaa-handoff` and `ddaa-passation` descriptions and still says
  "lightweight" / "léger". It was deliberately left alone so it would not
  diverge from `plugin.json` here. After releasing, update those two
  descriptions and versions there.

### Rejected approaches

- Editing only the marketplace copy. With `strict` left at its default, the
  plugin's own `plugin.json` wins, so a marketplace-only fix changes nothing
  the user sees.

### Additional context

The `handoff` repo's own README (line 166) also calls itself "the
lightweight, local pre-`/clear` snapshot"; a separate brief was dropped in
`../handoff/inbox/` for that. Keep the two descriptions of the split
consistent with each other.
