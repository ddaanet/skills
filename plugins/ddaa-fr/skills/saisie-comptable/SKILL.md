---
name: saisie-comptable
description: >-
  Intégrer des relevés bancaires périodiques dans un grand-livre CSV à
  double-entrée tenu à la main (Numbers, Excel, ou équivalent). Se déclenche
  sur "saisie comptable", "ventiler les relevés", "remplir tableau de
  comptes", "intégrer relevés bancaires", "tenue de comptes", "passer les
  relevés en CSV". Utiliser dès que l'utilisateur a des PDF de relevés
  bancaires et un template CSV/tableur à remplir. Particulièrement pertinent
  pour la comptabilité de petite structure (SCI, association, immeuble seul,
  petite entreprise) tenue à la main dans un tableur où chaque ligne doit
  s'équilibrer à zéro entre colonnes d'affectation. Ne PAS utiliser pour de
  l'extraction de transactions sans tableau cible.
---

# /saisie-comptable — Intégration relevés bancaires dans grand-livre CSV

Intégrer les écritures de relevés bancaires périodiques dans un
grand-livre CSV à double-entrée tenu à la main. Chaque ligne du
grand-livre s'équilibre à zéro entre les colonnes d'affectation, avec
l'impact trésorerie dans une colonne `Trésorerie` dédiée.

Voir `README.md` pour les décisions de conception.

## Quand utiliser /saisie-comptable

- L'utilisateur a un ou plusieurs PDF de relevés bancaires (ou autre source
  périodique de transactions) et un template CSV / tableur à remplir.
- Le grand-livre suit une convention de ligne équilibrée : une transaction
  par ligne, plusieurs colonnes d'affectation, total = 0.
- Une vérification contre un solde de clôture connu est attendue.

NE PAS utiliser quand :
- La sortie cible est un logiciel comptable (Sage, EBP, etc.) — conventions
  différentes.
- La tâche est de l'extraction pure de transactions sans tableau cible.

## Prérequis

Rassembler avant de commencer :

1. **CSV de référence d'une période précédente** — définit la structure
   des colonnes, les conventions de signe, et quelles colonnes sont
   pilotées par formules (à laisser vides) vs valeurs saisies.
2. **CSV vide du nouveau template** — confirme les colonnes attendues
   pour la période en cours (nouveaux comptes, nouvelles contreparties).
3. **PDF des relevés bancaires** — idéalement avec une couche texte. Si
   ce sont des scans, faire passer un OCR en amont et confirmer la qualité.
4. **Documents annexes** — relevés syndic, tableau d'amortissement de prêt,
   etc., nécessaires pour tracer les écritures non-trésorerie (appels de
   fonds, régularisations) et vérifier les soldes de clôture des comptes
   non-trésorerie.

Si l'un de ces éléments manque, le demander avant de continuer.

## Procédure

### 1. Caler les colonnes avant de coder

Confirmer la **liste exacte et l'ordre** des colonnes avec l'utilisateur
avant d'écrire la moindre ligne de code. Si le template a évolué depuis la
période précédente (nouveau bien, nouvelle contrepartie, nouveau syndic),
expliciter immédiatement :

- Colonnes à ajouter
- Colonnes à renommer
- Colonnes à supprimer
- Colonnes de sous-total qui existent uniquement pour les formules (à
  laisser vides en entrée CSV)

Toute ambiguïté restante (décomposition d'un loyer entre loyer et
provisions charges, attribution d'un paiement entre deux syndics) doit
soit être clarifiée d'entrée, soit être listée comme hypothèse explicite
à valider en fin de course.

### 2. Identifier les acteurs récurrents par leur libellé bancaire

Les relevés bancaires utilisent des libellés stables : `VIR REÇU [Nom]`,
`PRELEVEMENT EUROPEEN [Créancier]`, `ECHEANCE PRET N°...`, `CHEQUE [N]`.
Construire un mapping (mental ou dictionnaire Python explicite) entre
signature de libellé et colonnes du grand-livre.

Partout, *crédit* / *débit* désignent le sens du mouvement bancaire
(crédit = entrée, positif ; débit = sortie, négatif), pas les sens
comptables formels du grand-livre — qui sont inversés par rapport à cette
vue relevé.

Exemple :
- `VIR REÇU [Nom associé]` → crédit trésorerie + débit compte courant
  d'associé
- `PRELEVEMENT [Assureur]` → débit trésorerie + crédit colonne assurance
- `ECHEANCE PRET N°X` → débit trésorerie + capital + intérêts selon le
  tableau d'amortissement
- `CHEQUE N` → débit trésorerie + bénéficiaire (souvent syndic — croiser
  avec le relevé syndic pour désambiguïser quand plusieurs syndics
  coexistent)

Quand un libellé ne correspond à aucune signature connue, marquer la ligne
avec `[À CLASSIFIER]` dans le mémo et faire une affectation au mieux qui
équilibre la ligne. Ne pas zapper la ligne.

### 3. Double-entrée stricte : chaque ligne s'équilibre à zéro

Convention :
- **Colonne Trésorerie** reçoit l'impact bancaire effectif (positif crédit
  / négatif débit).
- **Toutes les autres colonnes d'affectation** contrebalancent l'impact
  trésorerie, leur somme = `-trésorerie`. La ligne complète somme à zéro.
- **Colonnes de solde** (solde trésorerie courant, capital restant dû,
  solde syndic) sont remplies uniquement quand connues — elles ne
  participent pas au contrôle d'équilibre.

Cas à surveiller :
- **Loyer avec provision charges** : ventiler entre `Loyer` et `Charges`.
  Les deux négatifs ; leur somme = `-crédit trésorerie`.
- **Échéance de prêt** : trésorerie négative, `Capital` + `Intérêts`
  positifs, décomposition prise dans le tableau d'amortissement.
- **Appel de fonds syndic** (ligne hors banque) : trésorerie vide, `Syndic`
  négatif, `Charges` (ou `Travaux`) positif — équilibre à zéro, pas
  d'impact trésorerie.
- **Régularisation** (commission remboursée, intérêts crédités) : signe
  opposé sur les mêmes colonnes que l'écriture d'origine.

### 4. Coder en Python, valider à la construction

Construire le CSV avec un petit script Python, jamais à la main. Centraliser
le constructeur de ligne :

```python
def L(date, memo, **mouvements):
    row = {col: "" for col in COLS}
    # "Zero" est un exemple de colonne de contrôle qui doit valoir 0 sur une
    # ligne équilibrée ; à renommer ou supprimer selon les colonnes réelles.
    row["Date"], row["Memo"], row["Zero"] = date, memo, 0.0
    total = 0.0
    for short, val in mouvements.items():
        if short in ("solde", "caprd", "soldsy"):
            continue
        row[KEY[short]] = val
        total += val
    if abs(total) > 0.001:
        raise ValueError(f"Ligne non balancée : {date} {memo} total={total}")
    # ... remplir colonnes de solde depuis kwargs ...
    return row
```

La validation à la construction attrape les erreurs de classification
immédiatement, quand elles sont encore faciles à corriger.

### 5. Trois vérifications obligatoires

Les trois doivent passer avant livraison :

1. **Cumul trésorerie** — solde initial + somme de la colonne trésorerie
   = solde final du dernier relevé. Doit tomber au centime.
2. **Soldes mensuels** — reconstituer le solde trésorerie en fin de chaque
   mois et comparer au `NOUVEAU SOLDE AU JJ/MM` du relevé correspondant.
   Toute divergence isole un mois précis à investiguer.
3. **Soldes de clôture des comptes non-trésorerie** — syndic, prêt, etc. :
   solde final du document annexe = solde final dans le CSV.

Si une vérification échoue, ne pas livrer. Corriger d'abord.

### 6. Format de sortie

- CSV séparé par virgules
- Point comme séparateur décimal
- Signe moins pour les négatifs, sans séparateur de milliers (sauf si le
  CSV de référence utilise un format comptable spécifique — s'aligner)
- Cellules vraiment vides pour les colonnes pilotées par formule (ex.
  `Solde`, `Capital restant dû` si calculé par cumul) ; ne pas écrire zéro
- En-tête sur 2 lignes : titre du tableau ligne 1, noms de colonnes
  ligne 2

### 7. Annoter les inconnues explicitement

Pour toute écriture bancaire dont la classification est incertaine, créer
la ligne avec une affectation plausible **en préfixant le mémo de
`[À CLASSIFIER]`**. La ligne reste équilibrée ; le CSV est utilisable ;
un `grep` sur le préfixe sort la liste de ce qu'il reste à valider.

Ne jamais omettre un mouvement bancaire — sinon le cumul trésorerie ne
tomberait plus juste.

### 8. Itérer, ne pas réécrire

Le premier jet n'est jamais le bon (décomposition de loyer mal devinée,
chèque mal attribué entre deux syndics, colonne ajoutée a posteriori).
Structurer le script Python pour qu'une correction se traduise par un
changement minimal — modifier une constante, renommer une clé, ajuster un
`if`/`else` — et regénérer. Ne pas réécrire le script de bout en bout à
chaque tour.

## Sortie

Un fichier CSV unique livré via `present_files`. Accompagner de :
- Confirmation en une ligne que les trois vérifications passent
- Liste des lignes `[À CLASSIFIER]` (s'il y en a) à valider
- Énoncé explicite des hypothèses prises (décomposition de loyer,
  attribution de chèque, etc.)

## Ce que /saisie-comptable ne fait pas

- Ne produit pas d'entrée pour logiciel comptable (Sage, EBP, etc.)
- Ne fait pas les déclarations fiscales
- Ne génère pas d'états financiers (bilan, compte de résultat) — uniquement
  le grand-livre brut
- Ne gère pas la bascule entre deux exercices (écritures de clôture,
  contre-passation) — c'est un autre workflow
