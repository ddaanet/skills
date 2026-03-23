# Skills Repo — CLAUDE.md

## Conventions

- **Commits :** gitmoji, messages denses orientés "pourquoi pas quoi"
- **Prose :** Opus uniquement. Qualité dense, pas de pipeline agent-core.
- **Langues :** Chaque skill est monolingue. DESIGN.md partagés en anglais.
- **Structure :** Paires bilingues groupées par concept (nom anglais).
  DESIGN.md au niveau groupe (pas dans le package). README.md généré au
  build avec lien GitHub vers le DESIGN.md. Skills standalone au niveau 1.
- **Remote git :** `github` (pas `origin`). `git push github main`.
- **Build :** `./build.sh` pour générer les .skill dans `dist/`.

## Arborescence

```
skills/
  brief/                       # groupe
    DESIGN.md                  # partagé, une seule copie
    brief-en/SKILL.md
    brief-fr/SKILL.md
  handoff/                     # groupe
    DESIGN.md
    handoff/SKILL.md (+references/)
    passation/SKILL.md (+references/)
  preflight/                   # groupe
    DESIGN.md
    preflight-en/SKILL.md (+references/)
    preflight-fr/SKILL.md (+references/)
  proof/                       # groupe
    DESIGN.md
    proof/SKILL.md (+references/)
    relecture/SKILL.md (+references/)
  bilingual-skill-creator/     # standalone
    DESIGN.md
    SKILL.md
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
