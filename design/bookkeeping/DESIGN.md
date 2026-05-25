# Bookkeeping Skill — Design Decisions

## Provenance

Distilled from a recurring claude.ai session pattern: integrating quarterly
or annual bank statement PDFs into a manually maintained Numbers (or Excel)
ledger for a small entity — in the originating case, a French SCI managing
two rental properties, with statements from the bank plus auxiliary
documents from a property syndic and a loan amortization table.

The pattern is general beyond the originating context: any small entity
that maintains its books in a spreadsheet rather than dedicated accounting
software, with a row-balanced double-entry convention, faces the same
workflow shape. Skill scope is generalized to that pattern; SCI-specific
examples appear in the skill body but the procedure is not SCI-bound.

## D-1: Two skills with different names (no suffix)

**Chosen:** `bookkeeping` (EN) and `saisie-comptable` (FR) as separate
skills with naturally different names.

**Reason:** The trigger keywords for this activity differ naturally between
the two languages:
- English speakers reach for "bookkeeping", "ledger entry", "data entry"
- French speakers reach for "saisie comptable", "tenue de comptes",
  "ventilation"

The "saisie" / "bookkeeping" pair is not a borrowed word in either
direction — they are genuinely native to their respective accounting
vocabularies. This matches the `passation` / `handoff` pattern, not the
`brief-fr` / `brief-en` pattern.

**Rejected:** A single skill with bilingual description (cross-lingual
contamination degrades triggering per MMLU-ProX). A shared suffixed name
like `bookkeeping-fr` (would feel unnatural in French — French speakers
do not call this "bookkeeping").

## D-2: Procedure-first, not template-first

**Chosen:** The skill teaches a *procedure* (8 numbered steps), not a
*template* (no `references/template.csv` shipped).

**Reason:** Every user's ledger is different — different column counts,
different sign conventions, different formula-driven cells. A shipped
template would be wrong for almost everyone. What is shared across users
is the *process*: frame columns first, identify libellé signatures, code
in Python with construction-time validation, run three verifications.

**Consequence:** Step 1 of the procedure ("Frame columns before coding")
is mandatory — the skill cannot proceed without grounding in the user's
specific ledger structure.

## D-3: Python tooling, not by-hand entry

**Chosen:** Every row is constructed by a Python script with a centralized
`L(date, memo, **moves)` function that validates balance to zero at
construction time.

**Reason:** Hand-entering 80-100 rows of double-entry data is error-prone;
each mis-allocation creates an unbalanced row that is invisible until the
year-end check fails (and then expensive to bisect). Python lets the
construction function refuse to create unbalanced rows, surfacing errors
at the point of misclassification when context is fresh.

Secondary benefit: corrections become localized edits (a constant, a key
rename) rather than re-doing rows manually.

## D-4: Three mandatory verifications

**Chosen:** Cumulative cash, monthly cash balances, year-end non-cash
account balances. All three required before delivery.

**Reason:** Each catches a different failure mode:

| Check | Catches |
|-------|---------|
| Cumulative cash | Missing or duplicated rows |
| Monthly balances | Date misalignment, mid-year errors that net out by year-end |
| Year-end non-cash | Misclassification between allocation columns |

A row that fails balance-to-zero is caught at construction. The remaining
ways to be wrong are caught by these three external-anchor checks. Without
all three, errors hide.

## D-5: [TO CLASSIFY] / [À CLASSIFIER] prefix convention

**Chosen:** Unclassified rows are kept in the CSV with a best-guess
balanced allocation and a `[TO CLASSIFY]` / `[À CLASSIFIER]` prefix in
the memo.

**Reason:** Two competing pressures:
- Skipping the row preserves classification correctness but breaks the
  cumulative cash check (the cash impact is real even if its other side
  is uncertain).
- Inventing an allocation preserves the cash check but pollutes
  downstream analysis.

The compromise: invent a balanced allocation so the CSV is usable
immediately, mark it explicitly so a `grep` retrieves the list of
to-be-validated rows.

**Note:** The prefix is translated — the English skill uses
`[TO CLASSIFY]`, the French uses `[À CLASSIFIER]`. The choice in each
language matches what the user would `grep` for naturally.

## D-6: Iteration over rewrite

**Chosen:** The Python script is structured so corrections are minimal
edits, not rewrites.

**Reason:** First-draft errors are almost guaranteed when the user has
not pre-specified every edge case (unknown lease decomposition, ambiguous
cheque attribution between multiple syndics, late column additions
discovered during review). The structure of the script matters less than
the fact that one correction = one localized change.

This is a meta-principle the skill teaches by example rather than enforces:
the Python sample in step 4 demonstrates a small, central `L()` function
and a `KEY` dict, which makes constant-time updates easy.

## D-7: Out of scope

The skill explicitly does **not** cover:
- Accounting software input formats (QuickBooks, Sage, EBP)
- Tax filing
- Financial statement generation (balance sheet, P&L)
- Year-end transition entries (closing, reversal)

**Reason:** Each of these is a distinct workflow with its own conventions.
Bundling them would dilute the skill's description and degrade triggering
accuracy. They are candidates for sibling skills.

## D-8: Auxiliary documents are first-class inputs

**Chosen:** The Prerequisites section requires syndic statements, loan
amortization tables, etc., not just bank statements.

**Reason:** Bank statements alone cannot decompose loan payments
(capital vs interest split lives in the amortization table), nor allow
year-end verification of the syndic account balance. Without these, the
third verification (non-cash account year-end balance) cannot run.

The skill flags missing auxiliary documents as a stop condition rather
than proceeding with assumptions.

## Lineage

This skill descends from a multi-session claude.ai workflow that
crystallized over several months of recurring bookkeeping tasks. The
prior turn ("distill a reusable procedure") in the originating session
produced the 8-step skeleton; the skill formalizes that distillation.
