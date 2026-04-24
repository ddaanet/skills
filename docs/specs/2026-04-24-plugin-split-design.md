# Plugin split: ddaa / ddaa-fr

Date: 2026-04-24

## Motivation

The repo currently ships a single Claude Code plugin (`ddaa`) bundling
nine skills across five design groups. A user interested in one command
(e.g. `/brief`) must install the whole set. Splitting by language
aligns with the project's "each skill is monolingual" principle and
keeps install scope tight: English users install `ddaa`, French users
install `ddaa-fr`. English is the baseline plugin and includes the
bilingual skill creator; French is the localized variant.

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

| Plugin   | Skills                                      | Invocations                                                      |
|----------|---------------------------------------------|------------------------------------------------------------------|
| ddaa     | brief, preflight, bilingual-skill-creator   | `ddaa:brief`, `ddaa:preflight`, `ddaa:bilingual-skill-creator`   |
| ddaa-fr  | brief, preflight                            | `ddaa-fr:brief`, `ddaa-fr:preflight`                             |

Inside each plugin the language is implicit from the plugin name; skill
directories and frontmatter names drop the `-en`/`-fr` suffix. A
given Claude Code project installs one plugin, not both.

## Repository layout

```
plugins/
  ddaa/
    .claude-plugin/plugin.json
    skills/
      brief/                       # was brief-en
      preflight/                   # was preflight-en
      bilingual-skill-creator/
  ddaa-fr/
    .claude-plugin/plugin.json
    skills/
      brief/                       # was brief-fr
      preflight/                   # was preflight-fr
skills/                            # claude.ai-only, outside plugin discovery
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

The repo-root `.claude-plugin/` is removed — the repo is no longer
itself a plugin. Claude Code auto-discovery only sees `SKILL.md` under
a plugin's own tree, so `skills/handoff/` and `skills/passation/` at
repo root are never installed as plugin skills.

## Plugin manifests

`plugins/ddaa/.claude-plugin/plugin.json` and
`plugins/ddaa-fr/.claude-plugin/plugin.json` follow the existing
manifest shape (name, version, description, author, license).
Descriptions are written in each plugin's target language.

## claude.ai `.skill` distribution

claude.ai has a flat, non-namespaced skill list, so the collision of
two skills both named `brief` has to be resolved at the archive level.
A user of claude.ai may install both EN and FR versions simultaneously.

`build.sh` handles disambiguation:

- For each skill under `plugins/ddaa/skills/*`: the archive is
  `<name>-en.skill`, the internal top-level directory is renamed to
  `<name>-en/`, and the `SKILL.md` frontmatter `name:` field is
  rewritten to `<name>-en`. (`brief` → `brief-en`, `preflight` →
  `preflight-en`, `bilingual-skill-creator` →
  `bilingual-skill-creator-en`.)
- For each skill under `plugins/ddaa-fr/skills/*`: same with `-fr`.
- For each skill under `skills/*` (handoff, passation): shipped as-is,
  no rewrite — names are already unambiguous.

The rewrite is done on a copy in a temp dir, zipped, and discarded —
source files are untouched.

### SKILL_GROUP map

Keyed by short skill name, used to look up the DESIGN.md link in the
generated `README.md` stub:

- `brief` → `brief`
- `preflight` → `preflight`
- `bilingual-skill-creator` → `bilingual-skill-creator`
- `handoff` → `handoff`
- `passation` → `handoff`

## Marketplace (separate repo `ddaanet/claude-plugins`)

Replace the single `ddaa` entry with two entries, each pointing into a
subdir of this repo via `source.path`:

```json
{
  "name": "ddaa",
  "source": {
    "source": "github",
    "repo": "ddaanet/skills",
    "path": "plugins/ddaa"
  },
  "description": "Skills — brief, preflight, skill creator.",
  ...
}
```

(and analogous `ddaa-fr` with a French description and
`path: "plugins/ddaa-fr"`).

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
