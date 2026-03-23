# Corpus de style par défaut

Référence de style utilisée quand le projet n'a ni `tmp/STYLE_CORPUS` ni
`STYLE_CORPUS.md`. Définit le ton et la structure pour les READMEs techniques.

---

## Voix : directe, assurée, utile

Écrire comme un ingénieur compétent qui explique son outil à un pair. Pas
de langage marketing, pas de précautions oratoires, pas de remplissage.

**Bien :**
> Extraction des retours utilisateurs depuis l'historique de conversation.
> Parcours récursif des sous-agents, filtrage du bruit, sortie JSON structurée.

**Mal :**
> Cet outil formidable vous permet d'extraire facilement de précieux retours
> de vos conversations ! Conçu pour être simple et puissant.

---

## Structure : Quoi, Comment, Détails

Ordonner les sections par ce que le lecteur cherche en premier :

1. **Ce que ça fait** -- une phrase, quel problème ça résout ?
2. **Installation** -- chemin le plus court vers un setup fonctionnel
3. **Usage** -- commandes réelles avec sortie réelle, cas courants d'abord
4. **Fonctionnalités** -- liste à puces des capacités (scannable)
5. **Configuration** -- options, variables d'environnement, réglages
6. **Développement** -- pour les contributeurs : build, test, lint
7. **Architecture** -- pour les curieux : choix de conception, structure des modules

Supprimer les sections qui n'apportent rien. Un README de trois sections
complet vaut mieux qu'un README de dix sections rempli de vide.

---

## Exemples de code : réels, minimaux, exécutables

Chaque exemple de code doit fonctionner par copier-coller. Montrer des
valeurs concrètes, pas des placeholders entre chevrons. Montrer 2-3
exemples couvrant les cas courants. Ajouter un commentaire uniquement
quand la commande n'est pas évidente.

---

## Exactitude technique

- Chaque commande doit refléter l'interface CLI réelle
- Chaque flag doit être réel et à jour
- Les arborescences de projet doivent correspondre au filesystem
- Les pré-requis de version doivent correspondre au fichier de config
- Les listes de dépendances doivent être à jour

Une documentation périmée est pire qu'une absence de documentation.

---

## Ton

| Contexte | Ton |
|----------|-----|
| Exemples d'usage | Minimal, pratique |
| Descriptions de fonctionnalités | Assuré, précis |
| Notes d'architecture | Technique, rigoureux |
| Messages d'erreur | Clair, actionnable |
| Avertissements | Direct, sans détour |

Ne jamais s'excuser, tergiverser, ou meubler. Énoncer les faits.
Donner les instructions. Avancer.
