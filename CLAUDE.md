# ddaanet — CLAUDE.md

## Conventions

- **Commits :** gitmoji, messages denses orientés "pourquoi pas quoi"
- **Prose :** Opus uniquement. Qualité dense, pas de pipeline agent-core.
- **Langues :** Chaque skill est monolingue. DESIGN.md partagés en anglais.
- **Structure :** Skills dans `plugins/<plugin>/skills/`. DESIGN.md dans
  `design/<groupe>/`, README.md injecté au build avec lien GitHub vers le
  DESIGN.md.
- **Plugins :** `ddaa` (EN, baseline), `ddaa-fr` (FR), `ddaa-handoff`
  (EN, passation/handoff résumé extrait), `ddaa-passation` (FR) —
  sous-dossiers de `plugins/`, auto-découverte `skills/*/SKILL.md` dans
  chacun. Le repo racine n'est plus lui-même un plugin. Le handoff résumé
  vit dans son propre plugin pour être un choix par projet, mutuellement
  exclusif avec le plugin `handoff` léger (n'en activer qu'un).
- **Distribution claude.ai :** `build.sh` réécrit les noms avec suffixe
  `-en` / `-fr` dans les archives `.skill` pour désambiguïser le
  namespace plat de claude.ai. Exception : `handoff` / `passation` ont
  des noms naturels distincts (DESIGN handoff D-1) et sont expédiés sans
  suffixe.
- **Remote git :** `github` (pas `origin`). `git push github main`.
- **Build :** `./build.sh` pour générer les .skill dans `dist/`.
- **Release :** `just release [patch|minor|major]`. Les quatre plugins
  (`ddaa`, `ddaa-fr`, `ddaa-handoff`, `ddaa-passation`) sont versionnés en
  **lockstep** (même version, tag unique `vX.Y.Z`). La recette bompe tous
  les manifests, tague, pousse, crée la GitHub release, puis bompe les
  entrées correspondantes du marketplace (`../claude-plugins`, ou
  `MARKETPLACE_DIR`) et le pousse. **Ne jamais éditer `.version` à la
  main** — un hook `version-guard` (PreToolUse) le refuse ; la recette est
  le seul chemin. Adaptée de `claude-plugin-dev` mais non vendorée (une
  seule occurrence ne justifie pas de généraliser le toolkit).

## Arborescence

```
plugins/
  ddaa/                          # plugin Claude Code — EN
    .claude-plugin/plugin.json
    skills/
      brief/
      preflight/
      proof/
      bilingual-skill-creator/
      bookkeeping/
  ddaa-fr/                       # plugin Claude Code — FR
    .claude-plugin/plugin.json
    skills/
      brief/
      preflight/
      relecture/
      saisie-comptable/
  ddaa-handoff/                  # plugin Claude Code — EN (résumé)
    .claude-plugin/plugin.json
    skills/
      handoff/
  ddaa-passation/                # plugin Claude Code — FR (résumé)
    .claude-plugin/plugin.json
    skills/
      passation/
design/                          # DESIGN.md par groupe (pas dans les packages)
  brief/DESIGN.md
  preflight/DESIGN.md
  proof/DESIGN.md
  handoff/DESIGN.md
  bilingual-skill-creator/DESIGN.md
  bookkeeping/DESIGN.md
build.sh
```

## Contenu

| Groupe | Skills | Plugin Claude Code | Description |
|--------|--------|--------------------|-------------|
| brief | brief (EN), brief (FR) | ddaa, ddaa-fr | Document de mission pour Claude Code |
| preflight | preflight (EN), preflight (FR) | ddaa, ddaa-fr | Validation pré-release |
| proof | proof (EN), relecture (FR) | ddaa, ddaa-fr | Relecture structurée élément-par-élément |
| bilingual-skill-creator | bilingual-skill-creator | ddaa | Créer un skill en deux langues |
| bookkeeping | bookkeeping (EN), saisie-comptable (FR) | ddaa, ddaa-fr | Intégrer relevés bancaires dans grand-livre CSV |
| handoff | handoff (EN), passation (FR) | ddaa-handoff, ddaa-passation | Résumé de fin de session (utile en projet hybride Claude Code + claude.ai) ; plugin séparé, choix par projet exclusif avec le plugin `handoff` léger |

## Lignée

Ces skills descendent de `agent-core` (claudeutils). La lignée est
documentée dans les DESIGN.md de chaque groupe.
