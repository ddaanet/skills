# Méthodologie : co-écriture bilingue de skills claude.ai

**Grounding:** Strong — 3+ frameworks/études externes, validés par le pattern interne brief-fr/brief-en.

## Fondement recherche

Sources :
- MMLU-ProX (Xuan et al., EMNLP 2025) — benchmark multilingue 29 langues, dégradation mesurée cross-linguistique
- Cross-Lingual Prompt Steerability (Zhang et al., Dec 2025) — prompts monolingues réduisent le language-switching parasite, +5-10% robustesse
- Lokalise blind study 2025 — Claude excelle en traduction nuancée (ton, idiomes, brand voice)
- Multilingual instruction tuning (Lin et al., SUMEval 2025) — corpus parallèles +9.9% vs monolingues en cross-lingual
- WMT 2025 — systèmes LLM dominent pour la cohérence documentaire

Principe clé validé : **réécriture native > traduction mécanique**. Les skills sont du texte procédural/instructionnel où le ton, les déclencheurs naturels, et la cohérence documentaire sont critiques.

## Procédure

### Phase 0 : Ancrage (appliquer /ground)

Avant toute écriture, rechercher l'état actuel de la recherche sur la performance LLM dans la paire de langues cible. Vérifier que les hypothèses du DESIGN.md D-1 tiennent encore. La recherche linguistique est un pré-requis, pas une option.

### Phase 1 : Écriture de la version source

Écrire le skill complet dans la langue source — celle qui est la plus naturelle pour le contenu et l'auteur. Ne pas tenter d'écrire les deux versions en parallèle : la version source stabilise les décisions, la structure, et les limites avant la réécriture.

### Phase 2 : Réécriture native de la version cible

La seconde version est une **réécriture complète**, pas une traduction :
- Mêmes décisions de design, même structure de sections
- Phrasé naturel dans la langue cible — un locuteur natif ne doit pas pouvoir deviner que c'est une traduction
- Les triggers/déclencheurs utilisent le vocabulaire naturel du domaine dans chaque langue
- Les exemples sont adaptés au contexte culturel si nécessaire

### Phase 3 : Alignement structurel

Vérifier la correspondance section par section :
- Chaque section du skill source existe dans le skill cible
- Les templates de référence sont intégralement traduits (pas de template anglais dans un skill français)
- Les exemples sont traduits ou adaptés
- Le DESIGN.md est partagé (écrit en anglais, langue de design commune)

### Phase 4 : Validation des descriptions YAML

La description YAML est le mécanisme de déclenchement — c'est le composant le plus critique :
- Doit lire naturellement dans la langue cible
- Doit contenir les mots-clés du domaine que l'utilisateur emploierait spontanément
- Pas de tokens de l'autre langue dans la description (dégradation mesurée par MMLU-ProX)
- Tester mentalement : "si j'écris [phrase typique], est-ce que cette description déclenche ?"

## Modèle de nommage

Deux cas selon la présence de conflit de noms :

**Avec suffixe** (modèle brief) : quand le mot-clé de déclenchement est identique dans les deux langues.
- `/brief-fr`, `/brief-en` — "brief" est utilisé tel quel en français professionnel
- Le suffixe est une concession au fait que le skill standard ne supporte qu'une description

**Sans suffixe** (modèle passation/handoff) : quand les mots-clés de déclenchement sont distincts.
- `/passation` (FR), `/handoff` (EN) — mots naturellement différents
- Pas besoin de suffixe, le nom lui-même distingue la langue

## Fichiers de référence

Chaque version linguistique possède ses propres fichiers de référence :
- `references/template.md` — intégralement dans la langue du skill
- `references/examples.md` — exemples dans la langue du skill
- `DESIGN.md` — partagé, en anglais (document d'architecture, pas d'usage)

## Ce que cette méthodologie ne couvre pas

- La traduction de contenu utilisateur (hors périmètre)
- Les skills monolingues (pas besoin de cette procédure)
- L'internationalisation à plus de 2 langues (nécessiterait un mécanisme de sélection)

## Sources

- MMLU-ProX: https://arxiv.org/abs/2503.10497
- Cross-Lingual Prompt Steerability: https://arxiv.org/abs/2512.02841
- Lokalise LLM translation study: https://lokalise.com/blog/what-is-the-best-llm-for-translation/
- CrossIn (SUMEval 2025): https://aclanthology.org/2025.sumeval-2.2/
- Multilingual Prompt Engineering Survey: https://arxiv.org/html/2505.11665v1
