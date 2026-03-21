---
name: relecture
description: >-
  Relecture structurée d'artefacts textuels. Passe en revue chaque élément
  avec un verdict forcé, accumule les décisions, applique en lot. Remplace
  le « ça te va ? » par une inspection élément par élément. Se déclenche
  sur « relecture », « relis », « révise », « vérifie », « passe en revue »,
  « valide mon texte », ou quand un artefact vient d'être généré et doit
  être validé avant envoi. Utiliser ce skill pour tout texte qui mérite une
  relecture attentive : lettre, rapport, documentation, message, article,
  spécification.
---

# Relecture — Validation structurée d'artefacts

Boucle de revue élément par élément. Présente chaque élément discret,
analyse, attend la réaction de l'utilisateur, classe en verdict interne,
accumule, applique en lot. Remplace la validation en un tour par une
inspection qui attrape les erreurs avant qu'elles ne partent.

Fondé sur l'inspection Fagan (détection par élément, reformulation,
verdict forcé) et la recherche sur la charge cognitive (segmentation en
~4 éléments simultanés — Cowan 2001).

## Source de l'artefact

L'artefact à relire peut être :

- **Un fichier** — chemin local ou uploadé. Lire le contenu avant de
  commencer.
- **Un texte dans la conversation** — le dernier texte généré, ou un texte
  collé par l'utilisateur. Le traiter comme artefact en mémoire.

Si la source n'est pas claire, demander.

## Protocole

### 1. Vue d'ensemble

Avant de toucher au premier élément, présenter :

- **Artefact :** quoi, pour qui, quel canal (si connu)
- **Éléments détectés :** nombre, granularité choisie. Voir
  `references/decoupe-elements.md` pour les règles de découpage.
- **Grille de lecture :** critères activés pour cette relecture (ton,
  exactitude factuelle, structure, concision, adéquation au destinataire —
  selon le type d'artefact)

Attendre la réponse de l'utilisateur avant le premier élément.
L'utilisateur peut : réordonner, passer des sections, ajuster le scope,
ou continuer tel quel.

**Ligne d'état :**

```
[relecture: vue d'ensemble <artefact> | décisions: 0]
```

### 2. Itération élément par élément

Présenter chaque élément dans l'ordre du document :

```
**Élément N/M : [titre ou début]**

[contenu de l'élément — texte brut]

Analyse : [observations factuelles — problèmes détectés ou confirmation
que l'élément est solide, avec justification courte]
```

Pas de raccourcis de verdict affichés. L'utilisateur réagit naturellement :
il commente, approuve, corrige, demande une suppression, ou passe à la
suite. L'agent déduit le verdict de la réponse (voir §Modèle de verdict).

**Analyse :** Évaluer contre la grille de lecture active. Signaler les
problèmes concrets. Si rien à signaler, dire pourquoi c'est bon — pas
juste « ok ». L'analyse aide l'utilisateur à prendre sa décision, elle
ne la remplace pas.

**Ligne d'état après chaque verdict déduit :**

```
[relecture: élément N/M | décisions: K]
```

### 3. Discussion

Si la réponse de l'utilisateur n'est pas directement classifiable en
verdict :

1. **Reformuler :** « Je comprends : [reformulation]. C'est ça ? »
   Attendre confirmation.
2. **Accumuler :** Chaque point validé s'ajoute aux décisions de cet
   élément.
3. **Converger vers un verdict** quand la discussion aboutit.

### 4. Actions pendant l'itération

Disponibles à tout moment, n'interrompent pas la boucle :

- **« point »** ou **« sync »** — afficher toutes les décisions
  accumulées
- **« revenir sur N »** — changer le verdict d'un élément déjà traité
  (par numéro, titre ou contenu). Nouveau verdict remplace l'ancien.
  Retour à la position courante après.

### 5. Fin de boucle

Quand tous les éléments sont traités, ou sur demande de l'utilisateur
(« on passe à la suite », « applique ») :

**Résumé des verdicts :**

```
N approuvé(s), N révisé(s), N supprimé(s), N passé(s)
```

Puis demander confirmation avant d'appliquer.

### 6. Application en lot

Appliquer toutes les décisions d'un coup :

- **Si l'artefact est un fichier :** éditer le fichier (str_replace ou
  Filesystem:edit_file) en appliquant les corrections de bas en haut
  (éviter les décalages de lignes).
- **Si l'artefact est un texte en conversation :** produire la version
  corrigée comme fichier téléchargeable (present_files).

**Ordre d'application :** de bas en haut dans le document pour que les
numéros de ligne restent valides.

### 7. Vérification

Après application, relire le résultat pour vérifier :

- Les corrections sont appliquées fidèlement
- Aucune erreur n'a été introduite par les modifications
- La cohérence globale du texte est préservée
- **Cohérence inter-éléments :** les corrections d'éléments distincts ne
  créent pas de redondance, de contradiction ou de rupture de ton entre
  eux. L'itération élément par élément crée un angle mort sur les
  interactions entre éléments — la vérification est le moment de le
  compenser.

Si un problème est détecté, le signaler à l'utilisateur avec une
proposition de correction. Ne pas modifier silencieusement.

## Modèle de verdict (interne)

L'utilisateur ne voit jamais ces catégories ni leurs raccourcis. L'agent
classe chaque réponse dans l'un des 4 verdicts :

| Verdict | L'utilisateur dit typiquement |
|---------|------------------------------|
| **approuver** | « ok », « c'est bon », « rien à dire », « next », « parfait », acquiescement implicite |
| **réviser** | donne une correction, reformule, dit « change X en Y », « plutôt comme ça », « je préfère… » |
| **supprimer** | « enlève ça », « on retire », « inutile », « supprime ce passage » |
| **passer** | « on verra plus tard », « pas sûr, on passe », « skip » |

**Règles de classification :**

- En cas de doute entre approuver et passer → **passer** (prudent).
- En cas de doute entre réviser et supprimer → **demander** (« tu veux
  reformuler ou retirer complètement ? »).
- Une réponse qui contient à la fois un commentaire et une approbation
  (« ok mais j'aurais peut-être… ») → **discussion**, pas verdict.
- L'absence de réaction explicite à un élément n'est jamais un verdict.
  Si l'utilisateur enchaîne sans se prononcer, rappeler l'élément en
  attente.

**Format d'accumulation interne :**

```
- V-1: [identifiant] — approuver
- V-2: [identifiant] — réviser : « [correction de l'utilisateur] »
- V-3: [identifiant] — supprimer
- V-4: [identifiant] — passer
```

## Anti-patterns

- **Validation en un tour :** « Ça te va ? » → « oui » → envoi. Pas de
  reformulation, pas d'accumulation. Rate les malentendus.
- **Édition immédiate :** Modifier le fichier pendant l'itération au lieu
  d'accumuler. Perd la trace des décisions, empêche l'application
  atomique.
- **Passage silencieux :** Avancer sans verdict déduit. Chaque élément
  reçoit une disposition — si l'utilisateur ne se prononce pas, lui
  rappeler.
- **Exposer les raccourcis :** Ne jamais afficher (a/r/s/p) ni les noms
  de verdict internes. L'utilisateur parle naturellement, l'agent classe
  en interne.
- **Analyse vide :** « Cet élément est bon. » sans justification. Si c'est
  bon, dire pourquoi en une phrase.
- **Navigation aléatoire :** Sauter à un élément arbitraire pendant
  l'itération. Présentation linéaire, « revenir sur » est post-traitement
  seulement.
