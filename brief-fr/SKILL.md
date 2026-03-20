---
name: brief-fr
description: >-
  Produire un document de mission pour Claude Code. Extraire decisions,
  contraintes et conclusions de la conversation courante. Se declenche sur
  "/brief", "brief pour claude code", "prepare un brief", "transfere le
  contexte au worktree". Utiliser quand la conception se fait dans claude.ai
  et l'execution dans Claude Code.
---

# /brief-fr — Document de mission pour Claude Code

Produit un fichier markdown à transmettre à un agent Claude Code. Le brief
existe parce que l'agent cible ne peut pas lire les conversations claude.ai —
contrainte d'isolation réelle.

Voir `DESIGN.md` pour les décisions de conception.

## Quand utiliser /brief vs /tag vs /passation

- `/brief` — cible Claude Code. Produit un document autonome (l'agent n'a pas accès à la conversation)
- `/tag` — cible une conversation future. Marqueur léger (la conversation est le contenu)
- `/passation` — cible une conversation future. Résumé d'ensemble pour continuer le travail

## Invocation

```
/brief
/brief refactoring auth vers OAuth2
```

Sans description, dériver le sujet de la conversation courante et confirmer.

## Processus

### 1. Identifier le périmètre

Déterminer quels sujets de la conversation doivent être briefés. Si la
conversation couvre plusieurs sujets, demander ou déduire lequel.

Ne pas briefer la conversation entière — c'est le travail de `/passation`.

### 2. Extraire le contexte pertinent

Parcourir la conversation pour le sujet ciblé. Extraire :

- **Décisions prises** — quoi et pourquoi (rationale)
- **Contraintes identifiées** — techniques, fonctionnelles, temporelles
- **Conclusions** — résultats d'analyse, consensus, arbitrages
- **Changements de scope** — ajouts, retraits, reports
- **Approches écartées** — et pourquoi (éviter de refaire le travail)
- **Références concrètes** — noms de fichiers, URLs, extraits de code, valeurs

Ne pas inclure : le déroulé de la discussion, les tentatives intermédiaires,
les échanges sociaux, le contexte que l'agent cible peut obtenir par
d'autres moyens (documentation existante, code source).

### 3. Produire le fichier

Générer un fichier markdown. Nommage : `brief-<sujet-kebab>.md`.

Structure :

```markdown
## Brief : <sujet>

<date>

### Décisions

- ...

### Contraintes

- ...

### Approches écartées

- ...

### Contexte supplémentaire

<tout ce qui est nécessaire pour agir sans accès à la conversation>
```

Longueur cible : 20-80 lignes. En dessous, probablement incomplet.
Au-dessus, vérifier qu'il n'y a pas de contenu superflu ou de narration.

### 4. Présenter et orienter

Présenter le fichier via `present_files`. Rappeler la destination :

> Brief prêt. À placer dans `plans/<plan>/brief.md` ou à fournir
> directement à l'agent worktree.

## Ce que le brief ne fait pas

- Ne résume pas la conversation entière (→ `/passation`)
- Ne pose pas de marqueur dans la conversation (→ `/tag`)
- Ne gère pas la transmission — l'utilisateur copie le fichier par le
  moyen de son choix (filesystem Desktop, copie manuelle, collé dans un prompt)
