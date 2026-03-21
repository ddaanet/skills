# Skills Repo — CLAUDE.md

## Conventions

- **Commits :** gitmoji, messages denses orientés "pourquoi pas quoi"
- **Prose :** Opus uniquement. Qualité dense, pas de pipeline agent-core.
- **Langues :** Chaque skill est monolingue. DESIGN.md partagés en anglais.
- **Structure :** Un dossier par skill. SKILL.md + DESIGN.md + references/ optionnel.
- **Remote git :** `github` (pas `origin`). `git push github main`.

## Contenu

Skills power-user pour claude.ai/Desktop :

| Skill | Langue | Description |
|-------|--------|-------------|
| bilingual-skill-creator | EN | Créer un skill en deux langues |
| brief-fr / brief-en | FR / EN | Document de mission pour Claude Code |
| passation / handoff | FR / EN | Résumé de fin de session |
| tag-fr / tag-en | FR / EN | Marqueur de conversation |
| relecture / proof | FR / EN | Validation structurée d'artefacts |

## Lignée

Ces skills descendent de `agent-core` (claudeutils). La lignée est documentée
dans les DESIGN.md respectifs, pas dans la structure git. Voir
`passation/DESIGN.md` D-2 pour la rationale.
