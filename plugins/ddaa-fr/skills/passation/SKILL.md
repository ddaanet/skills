---
name: passation
description: >-
  Préparer un résumé de passation pour continuer le travail dans un nouveau
  chat. Capturer le travail accompli, les tâches en attente, les blocages,
  et les enseignements ; livrer sur Notion (lien seul) quand c'est
  disponible. Se déclenche sur "/passation", "passation", "prépare une
  passation", "résume pour continuer demain", "conversation trop longue",
  "on reprend dans un nouveau chat", "fin", "au revoir". Utiliser quand
  l'utilisateur veut transférer le contexte vers une conversation future ou
  couper la session proprement.
---

# /passation — Résumé de fin de session

Prépare un document de passation pour continuer le travail dans une
nouvelle conversation. Transfert de contexte, pas documentation.

Voir `README.md` pour les décisions de conception.

## Quand utiliser /passation vs /brief

- `/passation` — cible une conversation future. Résumé d'ensemble du travail en cours
- `/brief` — cible Claude Code. Document de mission autonome (l'agent n'a pas accès à la conversation)

## Déclenchement

- **Explicite :** `/passation`, "prépare une passation", "résume pour
  continuer demain", "la conversation est trop longue, on repart à zéro".
- **Fin de session :** "fin", "au revoir". L'utilisateur veut couper la
  session proprement — déclencher la passation sans demander confirmation.

## Protocole

### 1. Rassembler le contexte

Parcourir la conversation pour identifier :
- Travail accompli — résultats, livrables, fichiers produits
- Tâches en attente — avec assez de contexte pour agir sans relire
- Blocages et points d'attention — causes racines, pas symptômes
- Décisions prises — quoi et pourquoi (rationale)
- Enseignements — patterns découverts, anti-patterns identifiés

### 2. Produire le document

Générer le contenu en markdown suivant le template dans
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

### 5. Livrer la passation

Deux voies selon l'environnement.

**Sur Notion (projet hybride, ou claude.ai avec Notion connecté) — voie privilégiée :**

1. Créer la page sous le parent pertinent — la page projet ou domaine que
   concerne la conversation — avec `notion-create-pages`. Si le parent est
   ambigu, le demander.
2. **Repositionner en tête.** `notion-create-pages` ajoute toujours la page
   en fin de liste du parent ; l'ordre voulu est chrono inverse (la plus
   récente en haut). Repositionner via `notion-update-page`
   command=`replace_content` : re-lister l'intégralité des blocs
   `<page url="…">` du parent dans l'ordre voulu, le nouveau en tête, avec
   le résumé une ligne à côté de chaque référence. Ne **pas** supprimer un
   bloc `<page>` isolé via `update_content` — ça l'envoie en corbeille
   (piège documenté dans les correctifs candidature).
3. **Pas de double génération.** Ne pas regénérer le contenu en fichier
   local ni utiliser `present_files`. Produire uniquement un lien
   `[Titre](url)` vers la page Notion. Même règle pour tout document déjà
   enregistré sur Notion : Notion fait foi.

**Sans Notion (claude.ai seul) :**

Présenter le fichier via `present_files`. Le document doit être prêt à être
collé dans le premier message d'une nouvelle conversation.

### 6. Afficher le titre de la session courante

Après livraison, suggérer un titre pour **la session qui se termine** — pas
la prochaine — afin de la retrouver dans l'historique claude.ai. Le placer
dans un bloc de code, sans le mot "titre" ni préfixe ("titre :"), juste le
texte :

```
Intégration API paiement — auth OAuth2 en place
```

Anti-pattern : afficher le titre de la *prochaine* conversation. Le titre
décrit ce qui s'est passé dans *cette* session, pas ce qui va suivre.

Terminer par une note courte sur la prochaine action immédiate.

## Ce que la passation ne fait pas

- Ne produit pas un document de mission pour Claude Code (→ `/brief`)
- Ne gère pas la transmission — l'utilisateur ouvre la page Notion ou copie
  le document par le moyen de son choix

## Ressources

- **`references/template.md`** — Structure du document de passation
- **`references/examples.md`** — Exemples de passations
