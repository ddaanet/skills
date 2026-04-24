# ddaanet

[Version française ci-dessous.](#ddaanet-fr)

Personal toolbox — bilingual skills for [claude.ai](https://claude.ai)
and [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

These are [Agent Skills](https://agentskills.io) — markdown
instructions that extend what Claude can do in a conversation. Each skill
is a self-contained directory with a `SKILL.md` and optional reference
files. This repo ships **two Claude Code plugins** (`ddaa`, `ddaa-fr`)
and builds `.skill` archives for claude.ai.

## Plugins & skills

| Skill | Plugin | Language | What it does |
|-------|--------|----------|--------------|
| brief | ddaa, ddaa-fr | EN, FR | Mission document for Claude Code |
| preflight | ddaa, ddaa-fr | EN, FR | Pre-release validation |
| proof / relecture | ddaa, ddaa-fr | EN, FR | Structured item-by-item proofreading |
| bilingual-skill-creator | ddaa | EN | Create a skill in two languages |

Inside a plugin, invocation is `ddaa:brief`, `ddaa-fr:preflight`, etc.
A given Claude Code project installs one plugin, not both.

### claude.ai-only skills

These aren't part of any Claude Code plugin. Download the `.skill`
archive from [Releases](https://github.com/ddaanet/skills/releases).

| Skill | Language | What it does |
|-------|----------|--------------|
| handoff | EN | Session wrap-up to continue in a new chat |
| passation | FR | Résumé de fin de session |

## Why bilingual pairs?

Skills are part of the agent's context. When the conversation, the
content, and the interactions are in French, having English instructions
in the middle breaks context homogeneity and leaks anglicisms into the
output. Each skill exists as a native rewrite in its target language,
not a mechanical translation. That principle extends to the plugin
boundary: `ddaa` is monolingual English, `ddaa-fr` monolingual French.

Details in each group's [`design/*/DESIGN.md`](design/).

## Install

### Claude Code (via marketplace)

```bash
claude /plugin marketplace add ddaanet/claude-plugins
claude /plugin install ddaa@ddaanet        # English
claude /plugin install ddaa-fr@ddaanet     # French
```

### claude.ai (Agent Skills)

Download a `.skill` file from [Releases](https://github.com/ddaanet/skills/releases),
or build from source:

```bash
./build.sh
ls dist/
```

claude.ai has no plugin namespace, so the build injects `-en` / `-fr`
suffixes into archive names: `brief-en.skill`, `brief-fr.skill`, etc.
`handoff` and `passation` ship as-is.

## Structure

```
plugins/
  ddaa/                          # Claude Code plugin (EN)
    .claude-plugin/plugin.json
    skills/{brief,preflight,proof,bilingual-skill-creator}/
  ddaa-fr/                       # Claude Code plugin (FR)
    .claude-plugin/plugin.json
    skills/{brief,preflight,relecture}/
skills/                          # claude.ai-only (outside plugin discovery)
  handoff/
  passation/
design/                          # architecture decisions per group
  brief/DESIGN.md
  preflight/DESIGN.md
  proof/DESIGN.md
  handoff/DESIGN.md
  bilingual-skill-creator/DESIGN.md
build.sh                         # .skill builder for claude.ai
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
et des fichiers de référence optionnels. Ce dépôt livre **deux plugins
Claude Code** (`ddaa`, `ddaa-fr`) et génère des archives `.skill` pour
claude.ai.

## Plugins & skills

| Skill | Plugin | Langue | Fait quoi |
|-------|--------|--------|-----------|
| brief | ddaa, ddaa-fr | EN, FR | Document de mission pour Claude Code |
| preflight | ddaa, ddaa-fr | EN, FR | Validation pré-release |
| proof / relecture | ddaa, ddaa-fr | EN, FR | Relecture structurée élément-par-élément |
| bilingual-skill-creator | ddaa | EN | Créer un skill en deux langues |

Dans un plugin, l'invocation est `ddaa:brief`, `ddaa-fr:preflight`, etc.
Un projet Claude Code donné installe un plugin, pas les deux.

### Skills claude.ai uniquement

Ces skills ne sont dans aucun plugin Claude Code. Télécharger l'archive
`.skill` depuis les [Releases](https://github.com/ddaanet/skills/releases).

| Skill | Langue | Fait quoi |
|-------|--------|-----------|
| handoff | EN | Session wrap-up to continue in a new chat |
| passation | FR | Résumé de fin de session |

## Pourquoi des paires bilingues ?

Les skills font partie du contexte de l'agent. Quand la conversation, le
contenu et les interactions sont en français, des instructions en anglais
au milieu cassent l'homogénéité du contexte et produisent des anglicismes
dans la sortie. Chaque skill est une réécriture native dans sa langue
cible, pas une traduction mécanique. Ce principe s'étend à la frontière
du plugin : `ddaa` est monolingue anglais, `ddaa-fr` monolingue français.

Détails dans les [`design/*/DESIGN.md`](design/) de chaque groupe.

## Installation

### Claude Code (via marketplace)

```bash
claude /plugin marketplace add ddaanet/claude-plugins
claude /plugin install ddaa@ddaanet        # anglais
claude /plugin install ddaa-fr@ddaanet     # français
```

### claude.ai (Agent Skills)

Télécharger un fichier `.skill` depuis les [Releases](https://github.com/ddaanet/skills/releases),
ou compiler depuis les sources :

```bash
./build.sh
ls dist/
```

claude.ai n'a pas de namespace plugin, donc le build injecte les
suffixes `-en` / `-fr` dans les noms d'archive : `brief-en.skill`,
`brief-fr.skill`, etc. `handoff` et `passation` sont expédiés tels
quels.

## Licence

MIT
