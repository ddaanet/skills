# Skills

[Version française ci-dessous.](#skills-fr)

Power-user skills for [claude.ai](https://claude.ai). Built for my own
workflows, published because why not.

These are [Agent Skills](https://agentskills.io) — markdown
instructions that extend what Claude can do in a conversation. Each skill
is a self-contained directory with a `SKILL.md` and optional reference
files.

## Skills

| Skill | Language | What it does |
|-------|----------|-------------|
| [brief-en](brief/brief-en/) | EN | Mission document for Claude Code |
| [brief-fr](brief/brief-fr/) | FR | Document de mission pour Claude Code |
| [handoff](handoff/handoff/) | EN | Session wrap-up to continue in a new chat |
| [passation](handoff/passation/) | FR | Résumé de fin de session |
| [preflight-en](preflight/preflight-en/) | EN | Pre-release validation |
| [preflight-fr](preflight/preflight-fr/) | FR | Validation pré-release |
| [proof](proof/proof/) | EN | Structured proofreading |
| [relecture](proof/relecture/) | FR | Relecture structurée |
| [bilingual-skill-creator](bilingual-skill-creator/) | EN | Create a skill in two languages |

## Why bilingual pairs?

Skills are part of the agent's context. When the conversation, the
content, and the interactions are in French, having English instructions
in the middle breaks context homogeneity and leaks anglicisms into the
output. Each skill exists as a native rewrite in its target language, not
a mechanical translation.

Details in each group's `DESIGN.md`.

## Install

Download a `.skill` file from [Releases](https://github.com/ddaanet/skills/releases),
or build from source:

```
./build.sh
ls dist/
```

## Structure

Bilingual pairs are grouped by concept. Each group has a shared
`DESIGN.md` with architecture decisions. Individual skills ship with a
`README.md` linking back here.

```
brief/
  DESIGN.md
  brief-en/SKILL.md
  brief-fr/SKILL.md
handoff/
  DESIGN.md
  handoff/SKILL.md (+references/)
  passation/SKILL.md (+references/)
...
```

## License

MIT

---

# Skills (FR)

Skills avancés pour [claude.ai](https://claude.ai). Construits pour mes
propres workflows, publiés parce que pourquoi pas.

Ce sont des [Agent Skills](https://agentskills.io) — des
instructions markdown qui étendent les capacités de Claude dans une
conversation. Chaque skill est un répertoire autonome avec un `SKILL.md`
et des fichiers de référence optionnels.

## Pourquoi des paires bilingues ?

Les skills font partie du contexte de l'agent. Quand la conversation, le
contenu et les interactions sont en français, des instructions en anglais
au milieu cassent l'homogénéité du contexte et produisent des anglicismes
dans la sortie. Chaque skill est une réécriture native dans sa langue
cible, pas une traduction mécanique.

Détails dans le `DESIGN.md` de chaque groupe.

## Installation

Télécharger un fichier `.skill` depuis les [Releases](https://github.com/ddaanet/skills/releases),
ou compiler depuis les sources :

```
./build.sh
ls dist/
```

## Licence

MIT
