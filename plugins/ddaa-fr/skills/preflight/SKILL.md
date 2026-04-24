---
name: preflight
description: >-
  Valide l'état git, lance les vérifications qualité, audite la documentation,
  et produit un verdict go/no-go avant de publier un package. Se déclenche sur
  "preflight", "prêt à livrer", "vérification release", "préparer la release",
  "pré-livraison", "on peut releaser ?", ou toute mention de publication de
  package. Utiliser ce skill avant chaque release, surtout quand on pense que
  c'est inutile -- c'est précisément là qu'il attrape des choses.
---

# Preflight

Valider les préconditions, auditer la documentation, produire un rapport de
conformité. La commande de release est exécutée par l'humain, pas par l'agent.

Les mises à jour de doc sont groupées en fin de cycle de développement :
hack, hack, hack, **preflight**, release.

## Étape 1 : Valider l'état git

Lancer en parallèle :

```bash
git branch --show-current
git status --porcelain
git fetch --dry-run 2>&1
git log @{u}..HEAD --oneline 2>/dev/null
git submodule status 2>/dev/null
```

| Vérification | Règle |
|--------------|-------|
| Branche | `main` ou `master` obligatoire. Sinon, arrêt. |
| Arbre de travail | Doit être propre. Sinon, arrêt. |
| Synchro remote | Pas de commits non poussés/tirés. Avertissement si divergence. |
| Sous-modules | Pas de modifications non commitées. Sinon, arrêt. |

## Étape 2 : Vérifier les tâches en attente

Chercher des marqueurs de tâches ouvertes dans les emplacements courants :

```bash
for f in TODO.md agents/session.md TASKS.md; do
  [ -f "$f" ] && grep -c '^\- \[ \]' "$f" && echo "  ^ dans $f"
done
```

Les tâches en attente sont un avertissement, pas un blocage. L'humain
décide s'il livre avant de les terminer.

## Étape 3 : Lancer les vérifications qualité

Détecter et lancer la suite de vérifications du projet. Essayer dans l'ordre :

```bash
just precommit 2>/dev/null \
  || just check 2>/dev/null \
  || make check 2>/dev/null \
  || npm test 2>/dev/null \
  || echo "AUCUN_CHECK_TROUVE"
```

Si aucune commande de check n'est trouvée, avertir et continuer. Si les
checks échouent, rapporter les échecs et arrêter. Tous les checks doivent
passer.

## Étape 4 : Mettre à jour la documentation

Lire le guide détaillé :

```
Read("references/documentation.md")
```

Deux audiences :

**Documentation publique (README.md) :**
- Chercher le corpus de style : `tmp/STYLE_CORPUS` > `STYLE_CORPUS.md` >
  `references/default-style-corpus.md` (inclus dans le skill)
- Auditer le README par rapport à l'état actuel (commits depuis le
  dernier tag, aide CLI, arborescence, dépendances)
- Réécrire les sections obsolètes en appliquant les conventions de style
- Vérifier que tous les exemples de code fonctionnent

**Documentation agentique (si présente) :**
- Descriptions de skills (`skills/*/SKILL.md`)
- `CLAUDE.md` et fragments : vérifier que les références pointent
  vers des fichiers existants
- Index mémoire : vérifier la cohérence des entrées

Commiter les modifications de documentation avant de passer au rapport.
La recette de release attend un arbre propre.

## Étape 5 : Évaluer la portée de la release

Montrer ce qui a changé depuis la dernière release :

```bash
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -n "$latest_tag" ]; then
  git log "${latest_tag}..HEAD" --oneline
else
  echo "Aucun tag trouvé. Commits récents :"
  git log --oneline -20
fi
```

Résumer : nombre de commits, changements clés regroupés par catégorie.

## Étape 6 : Détecter la version et l'outillage

**Type de projet** -- vérifier la présence de :
- `pyproject.toml` (Python)
- `package.json` (Node.js)
- `Cargo.toml` (Rust)

**Version courante** depuis le fichier de config détecté.

**Commande de release :**

```bash
just --list 2>/dev/null | grep -i release
```

Si une recette `release` existe, c'est la commande à utiliser. Sinon,
le signaler.

## Étape 7 : Rapport de conformité

```
## Rapport preflight

| Vérification        | Statut |
|---------------------|--------|
| Branche             | ok/ÉCHEC |
| Arbre propre        | ok/ÉCHEC |
| Synchro remote      | ok/attention |
| Checks qualité      | ok/ÉCHEC/attention (pas de runner) |
| Tâches en attente   | ok/attention (N en attente) |
| Documentation       | ok/mise à jour (N fichiers) |

**Version courante :** X.Y.Z
**Commits depuis la dernière release :** N
**Changements principaux :**
- résumé du changement 1
- résumé du changement 2

**Commande de release :**
  `just release`           # patch (défaut)
  `just release minor`     # mineure
  `just release major`     # majeure
```

Si un ÉCHEC : lister chaque problème avec des instructions de correction.
Arrêt.

Si tout est ok : confirmer la conformité et afficher la commande de release.

## Après le rapport

- Checks en échec : arrêt, l'humain corrige
- Tout ok : le skill termine, pas d'action supplémentaire
- Ne PAS invoquer d'autres skills ou commandes
- L'humain exécute la commande de release manuellement

## Contraintes

- **Ne jamais lancer la commande de release.** Réservée à l'humain.
- **Arrêt sur échec dur.** Branche, arbre propre, checks qualité sont
  des blocages. Arrêter et énumérer les corrections.
- **Avertissement sur problèmes souples.** Tâches en attente, runner
  manquant, divergence remote sont des avertissements. Informer, ne
  pas bloquer.
- **Pas de changement de version.** Ce skill évalue la conformité, il
  ne modifie pas les numéros de version.
- **Pas de suppression d'erreurs.** Ne jamais utiliser `|| true` ou
  avaler les codes de retour (exception : sondes de détection comme
  `2>/dev/null` pour les outils optionnels).
- **Signaler les échecs clairement.** Si quelque chose échoue, le dire
  et s'arrêter.
