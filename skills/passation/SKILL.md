---
name: passation
description: >-
  Préparer un résumé de passation pour continuer le travail dans un nouveau
  chat. Capturer le travail accompli, les tâches en attente, les blocages,
  et les enseignements. Se déclenche sur "/passation", "passation",
  "prépare une passation", "résume pour continuer demain", "conversation
  trop longue", "on reprend dans un nouveau chat". Utiliser quand
  l'utilisateur veut transférer le contexte vers une conversation future.
---

# /passation — Résumé de fin de session

Prépare un document de passation pour continuer le travail dans une
nouvelle conversation claude.ai. Transfert de contexte, pas documentation.

Voir `README.md` pour les décisions de conception.

## Quand utiliser /passation vs /brief

- `/passation` — cible une conversation future. Résumé d'ensemble du travail en cours
- `/brief` — cible Claude Code. Document de mission autonome (l'agent n'a pas accès à la conversation)

## Invocation

```
/passation
```

Ou en langage naturel : "prépare une passation", "résume pour continuer
demain", "la conversation est trop longue, on repart à zéro".

## Protocole

### 1. Rassembler le contexte

Parcourir la conversation pour identifier :
- Travail accompli — résultats, livrables, fichiers produits
- Tâches en attente — avec assez de contexte pour agir sans relire
- Blocages et points d'attention — causes racines, pas symptômes
- Décisions prises — quoi et pourquoi (rationale)
- Enseignements — patterns découverts, anti-patterns identifiés

### 2. Produire le document

Générer un fichier markdown suivant le template dans
**`references/template.md`**.

**Cible : 75-150 lignes de contenu.**
- En dessous de 75 : probablement incomplet
- 75-150 : équilibre entre détail et concision
- Au-dessus de 150 : vérifier si tout est nécessaire

### 3. Préserver les détails qui font gagner du temps

**Inclure :**
- Chemins de fichiers, URLs, références concrètes
- Décisions prises avec rationale
- Approches écartées et pourquoi (éviter de refaire le travail)
- Métriques, chiffres, données spécifiques
- Causes racines des problèmes, pas seulement les symptômes

**Omettre :**
- Déroulé pas à pas des actions
- Résultats évidents ou confirmations
- Debugging intermédiaire sans issue
- Information redondante

### 4. Documenter les enseignements

Format :

```markdown
## Enseignements

**[Sujet/Pattern] :**
- Découverte : [insight concret]
- Impact : [pourquoi ça compte]
- Recommandation : [comment appliquer]
```

Se concentrer sur : découvertes techniques, patterns d'outils efficaces,
améliorations de processus, anti-patterns à éviter.

### 5. Présenter le document

Présenter le fichier via `present_files`. Le document doit être prêt à
être collé dans le premier message d'une nouvelle conversation.

Terminer par une note courte sur la prochaine action immédiate.

## Ce que la passation ne fait pas

- Ne produit pas un document de mission pour Claude Code (→ `/brief`)
- Ne gère pas la transmission — l'utilisateur copie le document par le
  moyen de son choix

## Ressources

- **`references/template.md`** — Structure du document de passation
- **`references/examples.md`** — Exemples de passations
