# ddaanet — CLAUDE.md

## Conventions

- **Commits :** gitmoji, messages denses orientés "pourquoi pas quoi"
- **Prose :** Opus uniquement. Qualité dense, pas de pipeline agent-core.
- **Langues :** Chaque skill est monolingue. DESIGN.md partagés en anglais.
- **Structure :** Skills dans `plugins/<plugin>/skills/` (Claude Code) ou
  `skills/` (claude.ai uniquement). DESIGN.md dans `design/<groupe>/`,
  README.md injecté au build avec lien GitHub vers le DESIGN.md.
- **Plugins :** `ddaa` (EN, baseline) et `ddaa-fr` (FR) — sous-dossiers
  de `plugins/`, auto-découverte `skills/*/SKILL.md` dans chacun. Le
  repo racine n'est plus lui-même un plugin.
- **Distribution claude.ai :** `build.sh` réécrit les noms avec suffixe
  `-en` / `-fr` dans les archives `.skill` pour désambiguïser le
  namespace plat de claude.ai. Les skills sous `skills/` (handoff,
  passation) sont expédiés tels quels.
- **Remote git :** `github` (pas `origin`). `git push github main`.
- **Build :** `./build.sh` pour générer les .skill dans `dist/`.

## Arborescence

```
plugins/
  ddaa/                          # plugin Claude Code — EN
    .claude-plugin/plugin.json
    skills/
      brief/
      preflight/
      bilingual-skill-creator/
  ddaa-fr/                       # plugin Claude Code — FR
    .claude-plugin/plugin.json
    skills/
      brief/
      preflight/
skills/                          # claude.ai uniquement, hors plugin
  handoff/
  passation/
design/                          # DESIGN.md par groupe (pas dans les packages)
  brief/DESIGN.md
  preflight/DESIGN.md
  handoff/DESIGN.md
  bilingual-skill-creator/DESIGN.md
build.sh
```

## Contenu

| Groupe | Skills | Plugin Claude Code | Description |
|--------|--------|--------------------|-------------|
| brief | brief (EN), brief (FR) | ddaa, ddaa-fr | Document de mission pour Claude Code |
| preflight | preflight (EN), preflight (FR) | ddaa, ddaa-fr | Validation pré-release |
| bilingual-skill-creator | bilingual-skill-creator | ddaa | Créer un skill en deux langues |
| handoff | handoff (EN), passation (FR) | — (claude.ai seul) | Résumé de fin de session |

## Lignée

Ces skills descendent de `agent-core` (claudeutils). La lignée est
documentée dans les DESIGN.md de chaque groupe.
