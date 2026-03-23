# Découpage en éléments

Comment identifier les éléments à passer en revue. Le protocole principal
est dans SKILL.md — ce fichier fournit les règles de détection et de
découpage.

## Détection automatique

Analyser la structure de l'artefact pour identifier les éléments :

| Type d'artefact | Motif | Granularité |
|----------------|-------|-------------|
| Document structuré (headings) | Titres `##`, `###` | Section |
| Texte en paragraphes | Lignes vides | Paragraphe |
| Liste numérotée / à puces | Entrées de liste | Entrée |
| Formulaire multi-champs | Un champ = un élément | Champ |
| Code source | Fonction ou classe | Bloc |
| Diff | Marqueurs de hunk (`@@`) | Hunk |
| Message court (<100 mots) | Texte entier | Un seul élément |

**Repli :** Pas de structure détectée → un seul élément. La boucle tourne
une fois. La vue d'ensemble indique « 1 élément ».

## Découpage des éléments longs

Un élément se découpe en sous-éléments quand :

- **Sujets indépendants :** l'élément aborde 2+ sujets sans lien
  (surcharge de mémoire de travail — Cowan 2001, ~4 éléments simultanés)
- **Perte de contexte visuel :** l'élément dépasse un écran de contenu
- **Structure interne :** sous-titres, sous-listes, ou autres marqueurs
  de décomposition naturelle

Présenter les sous-éléments comme « N.1/N.K », « N.2/N.K ». Les
sous-éléments héritent de la position du parent dans l'ordre linéaire.

## Format d'accumulation

Les verdicts s'accumulent en mémoire pendant l'itération. La liste est
l'entrée structurée pour l'application en lot — l'agent travaille à
partir de cette liste, pas de sa mémoire de la discussion.

```
- V-1: [identifiant] — approuver
- V-2: [identifiant] — réviser : « [correction indiquée par l'utilisateur] »
- V-3: [identifiant] — supprimer
- V-4: [identifiant] — passer
```

**Identifiant :** titre ou début de l'élément. Doit être non ambigu dans
l'artefact.

**Détail de révision :** capturer la correction telle que formulée par
l'utilisateur — c'est la spécification d'édition pour l'application en
lot. La discussion peut affiner la correction avant l'enregistrement du
verdict.

## Application en lot

Sur confirmation de l'utilisateur après le résumé :

- **approuver** — pas de modification
- **réviser** — appliquer la correction indiquée
- **supprimer** — retirer l'élément
- **passer** — pas de modification (report explicite)

Appliquer de bas en haut dans le fichier pour éviter les décalages de
lignes entre corrections. Pour les artefacts composites (plusieurs
fichiers), appliquer par fichier indépendamment.

## Revenir sur un élément

Après avoir parcouru tous les éléments, l'utilisateur peut revenir sur
n'importe quel élément :

- Identification souple : par numéro, par titre, ou par description du
  contenu
- Correspondance sémantique — pas d'exigence de correspondance exacte
- Le nouveau verdict remplace l'ancien dans la liste d'accumulation
- Retour à l'état post-itération (pas de retour dans la séquence
  linéaire)
