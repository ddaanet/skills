# Extracting handoff/passation from the ddaa bundles

Date: 2026-06-12
Status: design, awaiting review

## Problem

There are two distinct "handoff" products in the ddaanet collection that
share the word *handoff*:

- **`handoff:handoff`** (standalone plugin) — ephemeral pre-`/clear` task
  snapshot, local markdown, deliberately narrow. Owns "save handoff",
  "before /clear", "wrap up", "I'm done".
- **`ddaa:handoff`** — full session *summary* (completed work, pending
  tasks, blockers, learnings) for resuming in a new chat, **delivered to
  Notion when it's available** (delivery is opportunistic, not the
  defining trait). Its description claims a very wide net: bare "handoff",
  "/handoff", "end", "goodbye".

Because both are installed globally, both skills are loaded at once, and
auto-triggering keys off each skill's `name` + `description` (not the
`plugin:` prefix). Two skills literally both named `handoff` with
overlapping trigger phrases compete — and `ddaa:handoff` is sometimes
chosen when `handoff:handoff` was wanted.

The user's goal: **handoff mode should be a per-project choice.** In some
projects the lightweight local snapshot is right; in others the
Notion-delivery summary is.

## Key constraints that shape the design

1. **The unit of per-project enable/disable is the *plugin*, not the
   skill** (`.claude/settings.json` `enabledPlugins`). So anything that
   must be a per-project choice has to live in its own plugin.
2. **Renaming a plugin does not stop auto-trigger collision** — only
   *not loading* the other skill does. If exactly one handoff provider is
   enabled per project, the collision disappears by construction, and the
   skill can keep its honest name `handoff` / `passation`.
3. **The collection is already language-split** (`ddaa` / `ddaa-fr`), with
   French skills using French names (`passation`, `relecture`,
   `saisie-comptable`). New plugins must respect that convention.

## Decision

Extract the resume-summary handoff out of the core bundles into its own
**language-split pair** of plugins, mutually exclusive per project with
the lightweight `handoff`.

| Plugin           | Skill        | Role                                   |
|------------------|--------------|----------------------------------------|
| `ddaa`           | (no handoff) | EN skill bundle, always on             |
| `ddaa-fr`        | (no passation)| FR skill bundle, always on            |
| `ddaa-handoff`   | `handoff`    | EN session summary to resume elsewhere |
| `ddaa-passation` | `passation`  | FR session summary to resume elsewhere |
| `handoff`        | `handoff`    | lightweight local pre-`/clear` snapshot|

Per project, enable **`handoff`** *or* the matching **`ddaa-handoff` /
`ddaa-passation`** — never both. With one handoff provider loaded there is
nothing to disambiguate, so the skills keep their correct names.

### Trigger parity

The handoff providers are interchangeable implementations of one slot, so
they must present the **same trigger surface** — the same phrases invoke
whichever handoff is enabled in the current project. Switching projects
must not silently change what your vocabulary does.

- `ddaa-handoff:handoff` and `handoff:handoff` (both EN) share one
  canonical English trigger set.
- `ddaa-passation:passation` carries the French translation of that set.

Parity is only safe *because* the providers are mutually exclusive: if two
EN handoffs were ever loaded, identical triggers would mean *guaranteed*
(not occasional) collision. So "enable exactly one" is not advice — it is a
load-bearing rule, and must be documented as such in every handoff
plugin's README.

The canonical set is the **union of today's two descriptions, kept
whole** — including the explicit end-of-conversation markers (`"end"`,
`"goodbye"`). Those mark a deliberate session close, which is exactly when
a handoff is wanted; the small risk of firing on a casual "goodbye" is
acceptable, and the agent has the context to not re-trigger when a handoff
was just produced. Settling the final wording is a small task during
implementation.

### Naming rationale

- The skill stays `handoff` / `passation` because that *is* what it is —
  the name documents itself. The earlier idea of renaming to a different
  verb (debrief/relay/recap) is dropped: it solved a collision that
  mutual-exclusion already solves, and "debrief" would shadow the existing
  `brief` skill.
- The plugin pair `ddaa-handoff` / `ddaa-passation` echoes the existing
  `ddaa` / `ddaa-fr` family and keeps French end-to-end (French users
  never meet the English word "handoff"). Preferred over `ddaa-handoff-fr`
  (forces the English name on a French plugin) and over `notion-handoff`
  (reads oddly as `notion-handoff-fr`, the family axis matters more than
  advertising the backend, and Notion isn't even the defining trait — just
  an opportunistic delivery target).

### Rejected alternatives

- **`ddaa-noha` / `ddaa-noha-fr`** (clone the whole bundle minus handoff):
  flips one skill by duplicating a 6-skill bundle, doubled again for FR =
  four near-identical bundles to maintain. Wrong axis.
- **Single bilingual `ddaa-handoff`** holding both skills: would be the one
  plugin that breaks the language-split convention, and would force a
  French-only project to also load the English `handoff` skill. EN/FR
  don't actually compete (different names, different-language triggers),
  so a bilingual plugin wouldn't malfunction — but the split is more
  regular.
- **Narrow `ddaa:handoff`'s triggers only** (no extraction): cheapest, but
  leaves handoff welded into ddaa, so it never becomes a per-project
  choice.

## Changes by repo

### `skills` repo (`/Users/david/code/skills`)

- **New `plugins/ddaa-handoff/`**: `.claude-plugin/plugin.json`,
  `skills/handoff/` (moved verbatim from `plugins/ddaa/skills/handoff`),
  README, justfile/precommit parity with the other plugins.
- **New `plugins/ddaa-passation/`**: same shape, `skills/passation/` moved
  from `plugins/ddaa-fr/skills/passation`.
- **`plugins/ddaa`**: remove `skills/handoff/`. Bump version. (Its
  `plugin.json` description already omits handoff; the marketplace entry
  does not — reconcile both.)
- **`plugins/ddaa-fr`**: remove `skills/passation/`. Bump version.

### `claude-plugins` repo (`/Users/david/code/claude-plugins`)

- **`.claude-plugin/marketplace.json`**: add `ddaa-handoff` and
  `ddaa-passation` entries (git-subdir of `ddaanet/skills`, paths
  `plugins/ddaa-handoff` / `plugins/ddaa-passation`); update the `ddaa`
  and `ddaa-fr` entries' descriptions + keywords to drop handoff/passation.

### `handoff` repo (`/Users/david/code/handoff`)

- Update the `handoff` skill's description to the **canonical trigger set**
  agreed for parity (if it differs from today's). Document the "enable
  exactly one handoff provider" rule in its README.

### Unaffected

- `onekeys` — its `h` default expands to `/handoff:handoff` (the
  lightweight one); unaffected. Worth a sanity check, no change expected.

## Migration / enablement notes

- A project that wants the resume-summary handoff enables `ddaa-handoff` (or
  `ddaa-passation`) in `.claude/settings.json` and does **not** enable
  `handoff`. The reverse for the lightweight one.
- Document the "enable exactly one" rule in each plugin's README so a
  future misconfiguration (both enabled) is a known, explained state
  rather than a surprise re-collision.

## Out of scope

- Merging the two handoff philosophies into one configurable plugin
  (different products: ephemeral local frame vs full resume-summary).
- Any change to what the handoff *does* — this is a packaging move only;
  skill content moves verbatim (aside from the parity trigger wording).

## Decisions

- **Version bumps: minor.** The collection is pre-1.0 and the removed
  skill is re-provided by `ddaa-handoff` / `ddaa-passation`, so a minor
  bump on `ddaa` / `ddaa-fr` suffices. The skills monorepo versions its
  plugins in **lockstep** (one version, one repo tag), so the two new
  plugins join at the current line (0.2.0) and are first released together
  with `ddaa` / `ddaa-fr` at 0.3.0 — not on independent version tracks.
  The standalone `handoff` repo releases separately (its own minor:
  0.6.2 → 0.7.0).
