# Plugin split: ddaa-en / ddaa-fr

Date: 2026-04-24

## Motivation

The repo currently ships a single Claude Code plugin (`ddaa`) bundling
nine skills across five design groups. A user interested in one command
(e.g. `/brief`) must install the whole set. Splitting by language
aligns with the project's "each skill is monolingual" principle and
keeps install scope tight: an English user installs only `ddaa-en`, a
French user only `ddaa-fr`.

## Scope changes

**Dropped entirely** (deleted from repo):
- `skills/proof/`, `skills/relecture/`
- `design/proof/`

Rationale: the proofreading loop is already integrated in `candidature`
and `superpowers`; standalone value is low.

**Kept in repo but excluded from Claude Code plugins** (claude.ai
`.skill` distribution only):
- `skills/handoff/`, `skills/passation/`
- `design/handoff/`

Rationale: Claude Code's automemory largely subsumes handoff; the
residual Stop-hook tool lives at `ddaanet/handoff`. The local skill
remains useful for plain claude.ai usage and Notion integration.

**Kept and split across two plugins:**

| Plugin   | Skills                                              |
|----------|-----------------------------------------------------|
| ddaa-en  | brief-en, preflight-en, bilingual-skill-creator     |
| ddaa-fr  | brief-fr, preflight-fr                              |

`bilingual-skill-creator` goes with EN: its frontmatter and body are
English, and it is the factory used once per new bilingual pair.

## Repository layout

```
plugins/
  ddaa-en/
    .claude-plugin/plugin.json
    skills/
      brief-en/
      preflight-en/
      bilingual-skill-creator/
  ddaa-fr/
    .claude-plugin/plugin.json
    skills/
      brief-fr/
      preflight-fr/
skills/                           # claude.ai-only, outside plugin discovery
  handoff/
  passation/
design/
  brief/DESIGN.md
  preflight/DESIGN.md
  handoff/DESIGN.md
  bilingual-skill-creator/DESIGN.md
build.sh
CLAUDE.md
README.md
```

The repo-root `.claude-plugin/` directory is removed — the repo is no
longer itself a plugin. Each subdir under `plugins/` is a plugin root.
Claude Code auto-discovery only sees `SKILL.md` files under a plugin's
own tree, so `skills/handoff/` and `skills/passation/` at repo root are
never installed as plugin skills.

## Plugin manifests

Both `plugins/ddaa-en/.claude-plugin/plugin.json` and
`plugins/ddaa-fr/.claude-plugin/plugin.json` follow the existing
`ddaa` manifest shape (name, version, description, author, license).
Descriptions are written in each plugin's target language.

## build.sh

- `SKILL_GROUP` map: drop the `proof` and `relecture` entries. The
  remaining seven stay: handoff, passation, brief-en, brief-fr,
  preflight-en, preflight-fr, bilingual-skill-creator.
- Detection is unchanged: `find . -name SKILL.md -not -path './dist/*'`
  still finds every skill wherever it lives in the tree. Skills under
  `plugins/*/skills/` and `skills/` are all picked up and built into
  `dist/*.skill`.
- The generated `README.md` stub (linking to `design/<group>/DESIGN.md`
  on GitHub) continues to work: `DESIGN.md` stays at repo root, and
  the link URL is computed from the group name, not the skill's
  filesystem path.

## Marketplace (separate repo `ddaanet/claude-plugins`)

Replace the single `ddaa` entry with two entries. Each uses
`source.path` to point into the subdir:

```json
{
  "name": "ddaa-en",
  "source": {
    "source": "github",
    "repo": "ddaanet/skills",
    "path": "plugins/ddaa-en"
  },
  "description": "Bilingual skills (EN) — brief, preflight, skill creator.",
  ...
}
```

(and analogous for `ddaa-fr`, with a French description).

## Docs

- `CLAUDE.md`: rewrite the "Arborescence" and "Contenu" sections to
  match the new layout and plugin set; drop proof/relecture lines.
- `README.md`: update install instructions to show both plugins; add a
  short note that `handoff`/`passation` are distributed as claude.ai
  `.skill` archives only.

## Out of scope

- No changes to the content of any surviving skill.
- No versioning bump strategy beyond incrementing the plugins'
  `version` field to `0.1.0` on first release.
- No migration shim for users of the old monolithic `ddaa` plugin;
  the marketplace entry is replaced outright.
