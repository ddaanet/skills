---
name: tag-fr
description: >-
  Déposer un marqueur recherchable dans la conversation courante. Le marqueur
  est un drapeau avec un libellé court généré par l'agent — le contenu c'est
  la conversation elle-même, pas le marqueur. Se déclenche sur "/tag", "/tag
  suivi d'une description", "tag ça", "marque ce point". Utiliser quand
  l'utilisateur veut rendre un moment de la conversation retrouvable.
---

# /tag — Marqueur de conversation

Dépose un drapeau recherchable dans le fil courant. Le contenu c'est la
conversation, le tag c'est juste l'adresse.

Voir `DESIGN.md` pour les décisions de conception.

## Quand utiliser /tag vs /brief vs /passation

- `/tag` — cible une conversation future. Marqueur léger (la conversation est le contenu)
- `/brief` — cible Claude Code. Document de mission autonome
- `/passation` — cible une conversation future. Résumé d'ensemble pour continuer le travail

## Invocation

Deux formes :

```
/tag
```

L'agent génère le libellé à partir du contexte précédent.

```
/tag le stockage des données ne devrait pas être dans le filesystem local
```

Le texte après `/tag` fournit du contexte. L'agent génère quand même un
libellé condensé — le texte de l'utilisateur n'est pas recopié tel quel.

## Ce que produit le tag

```
🏷️ stockage données candidature dans mémoire projet
```

Un emoji drapeau suivi d'un libellé de quelques mots. Pas de date, pas de
slug, pas de métadonnées. Le libellé sert de vecteur de recherche.

## Récupération

Depuis un autre chat, `conversation_search` retrouve le tag via les mots
du libellé ou du contexte environnant.

## Ce que le tag ne fait pas

- Ne résume pas la discussion — la conversation est le contenu
- Ne duplique pas le message de l'utilisateur
- Ne produit pas de fichier ni d'artifact
- Ne se substitue pas à la passation
