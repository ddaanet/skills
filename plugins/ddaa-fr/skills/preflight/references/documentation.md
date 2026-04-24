# Guide d'audit documentaire

Guide détaillé pour l'étape de mise à jour de la documentation dans preflight.
Les mises à jour de doc sont groupées en fin de cycle : hack, hack, hack,
preflight, release.

## Deux audiences

### Documentation publique (README.md)

Le README est la vitrine du projet. Il doit refléter le soin apporté au code.

**Corpus de style :** chercher `tmp/STYLE_CORPUS` d'abord (échantillons
propres au projet). Puis `STYLE_CORPUS.md` à la racine du dépôt. Si aucun
n'existe, utiliser `references/default-style-corpus.md`. Lire le corpus
avant d'écrire pour s'imprégner du ton.

**Processus de mise à jour :**

1. Lire le corpus de style pour intégrer les conventions
2. Lire le README actuel
3. Identifier les sections obsolètes en comparant avec :
   - Commits depuis le dernier tag (étape 5)
   - Commandes CLI : `<outil> --help` pour chaque sous-commande
   - Arborescence du projet : layout `src/`, fichiers de test
   - Dépendances : `pyproject.toml` / `package.json` / `Cargo.toml`
4. Réécrire les sections obsolètes en appliquant le corpus de style
5. Vérifier que tous les exemples de code fonctionnent (commandes, flags, sortie)
6. Vérifier la cohérence interne (liste de fonctionnalités vs sections d'usage)

**Signes courants d'obsolescence :**
- Nouvelles sous-commandes CLI non documentées
- Flags ou arguments modifiés
- Arborescences de projet périmées
- Pré-requis de version modifiés
- Nouvelles dépendances non documentées
- Fonctionnalités supprimées encore listées
- Sortie des exemples ne correspondant plus au comportement actuel

**Principes de style :**
- Commencer par ce que l'outil fait, pas par les détails d'implémentation
- Montrer l'usage réel avant d'expliquer le fonctionnement interne
- Exemples de code minimaux et exécutables
- Chaque section doit mériter sa place

### Documentation agentique (si présente)

La documentation agent cible les LLMs et l'automatisation. Critère de
qualité différent : précision, découvrabilité, déclencheurs structurés.
N'auditer ces fichiers que s'ils existent dans le projet.

**Descriptions de skills** (`skills/*/SKILL.md` frontmatter) :
- Vérifier que les phrases de déclenchement correspondent à l'usage réel
- Ajouter les déclencheurs découverts pendant le développement
- Retirer ceux liés à des fonctionnalités supprimées

**CLAUDE.md et fragments :**
- Vérifier que les références fichiers pointent vers des fichiers existants
- Vérifier que les règles comportementales correspondent à l'implémentation
- Confirmer que les descriptions de workflow sont à jour

**Index mémoire :**
- Vérifier que les entrées pointent vers des fichiers existants
- Vérifier que les descriptions contiennent des mots-clés pertinents
- Pas d'entrées en doublon

**Ignorer la doc agentique** quand rien n'a changé dans ce domaine pendant
le cycle. Se concentrer sur ce qui a été modifié.

## Audit guidé par le diff

Se concentrer sur ce qui a changé, pas sur l'ensemble :

1. Récupérer les commits depuis le dernier tag (déjà disponible à l'étape 5)
2. Catégoriser : nouvelles fonctionnalités, APIs modifiées, suppressions, infra
3. Pour chaque catégorie, identifier les sections de documentation concernées
4. Mettre à jour uniquement les sections touchées

Cela évite les modifications superflues dans la documentation stable.

## Stratégie de commit

Les mises à jour de documentation doivent être commitées avant le rapport :

1. Terminer toutes les mises à jour de doc
2. Stager les fichiers de documentation
3. Commiter avec un message descriptif
4. Passer au rapport de conformité (étape 7)

La recette de release attend un arbre de travail propre.
