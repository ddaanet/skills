# Exemples de passation

Exemples concrets illustrant les bonnes pratiques.

## Exemple 1 : Projet technique

```markdown
# Passation : Intégration API de paiement

**État :** Authentification OAuth2 implémentée, tests des endpoints restants à faire

## Travail accompli

**Système d'authentification :**
- Flow OAuth2 avec refresh token, testé en staging
- Credentials stockés via keychain
- Classe wrapper : `/home/claude/project/api/auth_client.py`

**Client HTTP de base :**
- Retry avec backoff exponentiel (3 tentatives, jitter aléatoire)
- Logging requête/réponse pour debug
- Gestion du rate limiting (100 req/min)

## En attente / Prochaines étapes

- [ ] **Tester les endpoints restants** (PRIORITÉ)
  - À vérifier : /users, /data/export, /webhooks/subscribe
  - Suite de tests : `tests/integration/test_api.py`
  - Clé API staging dans `.env.staging`

- [ ] **Gestion des erreurs réseau**
  - Implémentation actuelle suppose une connexion stable
  - À gérer : timeouts, erreurs de connexion, réponses 5xx

## Blocages / Points d'attention

**Rate limiting sans Retry-After :**
- Quoi : L'API renvoie 429 sans header Retry-After
- Pourquoi : Bug côté serveur (confirmé avec l'équipe)
- Impact : Backoff fixe de 60s obligatoire
- Contournement : Sleep hardcodé dans rate_limit_handler()

**Timing du refresh token :**
- Décision : Rafraîchir 5 minutes avant expiration (pas 1 minute)
- Rationale : Les délais réseau causent des race conditions à 1 minute
- Alternatives écartées : Refresh à 1 minute (risque de token expiré mid-request)

## Enseignements

**Backoff exponentiel :**
- Découverte : Sans jitter, tous les retries se déclenchent en même temps sous charge (thundering herd)
- Recommandation : `random.uniform(0, base_delay * 2 ** attempt)` pour le backoff

## Contexte pour la prochaine conversation

Lancer la suite de tests : `pytest tests/integration/test_api.py -v`.
L'auth passe. Se concentrer sur les trois endpoints non testés. Credentials
staging dans `.env.staging`.
```

## Exemple 2 : Travail de conception (skills)

```markdown
# Passation : Conversion skills agent-core vers claude.ai

**État :** Skills brief-fr/brief-en terminés et installés. Passation/handoff en cours de conception.

## Travail accompli

**Méthodologie i18n :**
- Document de méthodologie grounded (EMNLP/WMT 2025)
- Principe : réécriture native, pas traduction mécanique
- Deux skills séparés par langue, DESIGN.md partagé en anglais

**Skills brief-fr et brief-en :**
- Installés dans `/mnt/skills/user/`
- DESIGN.md partagé documentant 7 décisions (D-1 à D-7)
- Modèle de référence pour la co-écriture bilingue

## En attente / Prochaines étapes

- [ ] **Créer passation (FR) et handoff (EN)** (PRIORITÉ)
  - Réécriture native de conversation-handoff existant
  - Template et exemples dans chaque langue
  - DESIGN.md partagé

- [ ] **Installer les skills** dans `/mnt/skills/user/`

## Blocages / Points d'attention

**conversation-handoff existant :**
- Décision : Remplacer par passation + handoff (deux skills distincts)
- Rationale : Cohérence avec le modèle i18n, refs en langue du skill
- L'ancien skill reste en place jusqu'à l'installation des nouveaux

## Enseignements

**Conversion ne vaut pas portage :**
- Découverte : Les contraintes claude.ai et Claude Code sont différentes, donc les solutions doivent l'être
- Impact : brief existe parce que l'agent Code est isolé de la conversation
- Recommandation : Toujours partir des contraintes du contexte cible, pas de l'implémentation source

## Contexte pour la prochaine conversation

Continuer la création des skills passation/handoff.
La méthodologie i18n est documentée dans `methodology-skill-i18n.md`.
Le DESIGN.md de brief-fr sert de modèle pour les DESIGN.md des autres
paires de skills.
```

## Patterns d'une bonne passation

**Concret :**
- Bon : "Fichier dans `/home/claude/project/api/auth_client.py`"
- Mauvais : "Le fichier d'authentification"

**Contextualisé :**
- Bon : "Refresh 5 min avant expiration car 1 min causait des race conditions"
- Mauvais : "On a changé le timing du refresh"

**Actionnable :**
- Bon : "Lancer `pytest tests/integration/test_api.py -v` sur les trois endpoints"
- Mauvais : "Faut tester d'autres endpoints"

**Causes racines :**
- Bon : "L'API renvoie 429 sans Retry-After (bug serveur confirmé)"
- Mauvais : "Le rate limiting marche pas bien"
