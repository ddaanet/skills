# ddaanet — CLAUDE.md

## Conventions

- **Commits :** gitmoji, messages denses orientés "pourquoi pas quoi"
- **Prose :** Opus uniquement. Qualité dense, pas de pipeline agent-core.
- **Langues :** Chaque skill est monolingue. DESIGN.md partagés en anglais.
- **Structure :** Skills dans `skills/`, DESIGN.md dans `design/<groupe>/`.
  README.md généré au build avec lien GitHub vers le DESIGN.md.
- **Plugin :** `ddaanet` — même repo sert de plugin Claude Code
  (auto-découverte `skills/*/SKILL.md`) et de source pour les `.skill`
  claude.ai (via `build.sh`).
- **Remote git :** `github` (pas `origin`). `git push github main`.
- **Build :** `./build.sh` pour générer les .skill dans `dist/`.

## Arborescence

```
.claude-plugin/plugin.json     # manifeste plugin Claude Code
skills/                        # auto-découverte plugin
  brief-en/SKILL.md
  brief-fr/SKILL.md
  handoff/SKILL.md (+references/)
  passation/SKILL.md (+references/)
  preflight-en/SKILL.md (+references/)
  preflight-fr/SKILL.md (+references/)
  proof/SKILL.md (+references/)
  relecture/SKILL.md (+references/)
  bilingual-skill-creator/SKILL.md
design/                        # DESIGN.md par groupe (pas dans les packages)
  brief/DESIGN.md
  handoff/DESIGN.md
  preflight/DESIGN.md
  proof/DESIGN.md
  bilingual-skill-creator/DESIGN.md
```

## Contenu

| Groupe | Skills | Description |
|--------|--------|-------------|
| brief | brief-fr, brief-en | Document de mission pour Claude Code |
| handoff | passation, handoff | Résumé de fin de session |
| preflight | preflight-fr, preflight-en | Validation pré-release |
| proof | relecture, proof | Validation structurée d'artefacts |
| (standalone) | bilingual-skill-creator | Créer un skill en deux langues |

## Lignée

Ces skills descendent de `agent-core` (claudeutils). La lignée est
documentée dans les DESIGN.md de chaque groupe.
