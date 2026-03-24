# ddaanet

[Version française ci-dessous.](#ddaanet-fr)

Personal toolbox — bilingual skills for [claude.ai](https://claude.ai)
and [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

These are [Agent Skills](https://agentskills.io) — markdown
instructions that extend what Claude can do in a conversation. Each skill
is a self-contained directory with a `SKILL.md` and optional reference
files. The same repo serves as a **Claude Code plugin** (auto-discovered
skills) and builds `.skill` archives for claude.ai.

## Skills

| Skill | Language | What it does |
|-------|----------|-------------|
| [brief-en](skills/brief-en/) | EN | Mission document for Claude Code |
| [brief-fr](skills/brief-fr/) | FR | Document de mission pour Claude Code |
| [handoff](skills/handoff/) | EN | Session wrap-up to continue in a new chat |
| [passation](skills/passation/) | FR | Résumé de fin de session |
| [preflight-en](skills/preflight-en/) | EN | Pre-release validation |
| [preflight-fr](skills/preflight-fr/) | FR | Validation pré-release |
| [proof](skills/proof/) | EN | Structured proofreading |
| [relecture](skills/relecture/) | FR | Relecture structurée |
| [bilingual-skill-creator](skills/bilingual-skill-creator/) | EN | Create a skill in two languages |

## Why bilingual pairs?

Skills are part of the agent's context. When the conversation, the
content, and the interactions are in French, having English instructions
in the middle breaks context homogeneity and leaks anglicisms into the
output. Each skill exists as a native rewrite in its target language, not
a mechanical translation.

Details in each group's [`design/*/DESIGN.md`](design/).

## Install

### Claude Code (plugin)

```bash
claude /install-plugin /path/to/this/repo
```

### claude.ai (Agent Skills)

Download a `.skill` file from [Releases](https://github.com/ddaanet/skills/releases),
or build from source:

```bash
./build.sh
ls dist/
```

## Structure

Skills live in `skills/*/SKILL.md` (auto-discovered by Claude Code).
Design docs live in `design/*/DESIGN.md`, one per bilingual group — never
duplicated, never shipped in packages. Build generates a temporary
`README.md` per skill with a link back to the design doc.

```
.claude-plugin/plugin.json     # Claude Code plugin manifest
skills/                        # all skills (flat)
  brief-en/SKILL.md
  brief-fr/SKILL.md
  handoff/SKILL.md (+references/)
  passation/SKILL.md (+references/)
  ...
design/                        # architecture decisions per group
  brief/DESIGN.md
  handoff/DESIGN.md
  ...
build.sh                       # .skill builder for claude.ai
```

## License

MIT

---

# ddaanet (FR)

Boîte à outils personnelle — skills bilingues pour
[claude.ai](https://claude.ai) et
[Claude Code](https://docs.anthropic.com/en/docs/claude-code).

Ce sont des [Agent Skills](https://agentskills.io) — des
instructions markdown qui étendent les capacités de Claude dans une
conversation. Chaque skill est un répertoire autonome avec un `SKILL.md`
et des fichiers de référence optionnels. Le même dépôt sert de **plugin
Claude Code** (skills auto-découverts) et génère des archives `.skill`
pour claude.ai.

## Pourquoi des paires bilingues ?

Les skills font partie du contexte de l'agent. Quand la conversation, le
contenu et les interactions sont en français, des instructions en anglais
au milieu cassent l'homogénéité du contexte et produisent des anglicismes
dans la sortie. Chaque skill est une réécriture native dans sa langue
cible, pas une traduction mécanique.

Détails dans les [`design/*/DESIGN.md`](design/) de chaque groupe.

## Installation

### Claude Code (plugin)

```bash
claude /install-plugin /chemin/vers/ce/dépôt
```

### claude.ai (Agent Skills)

Télécharger un fichier `.skill` depuis les [Releases](https://github.com/ddaanet/skills/releases),
ou compiler depuis les sources :

```bash
./build.sh
ls dist/
```

## Licence

MIT
