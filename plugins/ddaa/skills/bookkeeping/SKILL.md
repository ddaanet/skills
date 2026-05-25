---
name: bookkeeping
description: >-
  Integrate periodic bank statements into a manually maintained double-entry
  CSV ledger (Numbers, Excel, or similar). Triggers on "bookkeeping", "ledger
  import", "process bank statements", "fill accounts spreadsheet", "integrate
  statements into ledger", "bank statements to CSV". Use whenever the user
  has bank statement PDFs and a CSV/spreadsheet ledger template to populate.
  Especially relevant for small-entity accounting (SCI, association, single
  property, small business) maintained by hand in a spreadsheet, where each
  ledger row must balance to zero across allocation columns. Do NOT use for
  pure data-extraction tasks unrelated to a ledger template.
---

# /bookkeeping — Bank Statements to Ledger CSV

Integrate periodic bank statement entries into a manually maintained
double-entry CSV ledger. Each row in the ledger balances to zero across
allocation columns, with the cash impact in a dedicated `Trésorerie` /
`Cash` column.

See `README.md` for design decisions.

## When to use /bookkeeping

- The user has one or more bank statement PDFs (or other periodic transaction
  source) and a CSV / spreadsheet ledger template to populate.
- The ledger uses a row-balanced convention: one transaction per row, multiple
  allocation columns, total = 0.
- Verification against a known closing balance is expected.

Do NOT use when:
- The output is general accounting software input (QuickBooks, etc.) — different
  conventions apply.
- The task is pure transaction extraction with no target ledger structure.

## Prerequisites

Before starting, gather:

1. **Reference CSV from a previous period** — defines the column structure,
   sign conventions, and which columns are formula-driven (must stay empty)
   vs entered values.
2. **Empty template CSV for the new period** — confirms the expected
   columns for the current period (new accounts, new counterparties).
3. **Bank statement PDFs** — preferably with a text layer. If they are scans,
   run OCR upstream and confirm sufficient quality.
4. **Auxiliary documents** — syndic statements, loan statements, etc., needed
   to track non-cash entries (fund calls, regularizations) and to verify
   closing balances of non-cash accounts.

If any of these are missing, ask before proceeding.

## Procedure

### 1. Frame columns before coding

Confirm the **exact column list and order** with the user before writing any
code. If the template has evolved since the last period (new property, new
counterparty, new syndic), call this out explicitly:

- New columns to add
- Columns to rename
- Columns to remove
- Subtotal columns that exist purely for formulas (must remain empty in
  the CSV input)

Any remaining ambiguity (rent decomposition into rent + charges, attribution
of a payment between two syndics) must either be clarified up front, or
listed as an explicit assumption to validate at the end.

### 2. Identify recurring parties by libellé signature

Bank statements use stable libellé patterns: `VIR REÇU [Name]`,
`PRELEVEMENT EUROPEEN [Creditor]`, `ECHEANCE PRET N°...`, `CHEQUE [N]`.
Build a mental (or explicit Python dict) mapping from libellé signature to
ledger columns.

Throughout, *credit* / *debit* refer to the sign of the bank movement
(credit = money in, positive; debit = money out, negative), not the formal
accounting ledger sides — which are inverted from this bank-statement view.

Example mapping:
- `VIR REÇU [Owner Name]` → cash credit + owner-account debit (current account)
- `PRELEVEMENT [Insurer]` → cash debit + insurance-column credit
- `ECHEANCE PRET N°X` → cash debit + capital + interest split per loan
  statement
- `CHEQUE N` → cash debit + recipient (often syndic — match number to
  syndic statement to disambiguate when multiple syndics exist)

When a libellé does not match any known signature, mark the line with
`[TO CLASSIFY]` in the memo and a best-guess allocation that still
balances. Do not skip the line.

### 3. Strict double-entry: each row balances to zero

Convention:
- **Cash column** receives the actual bank impact (positive credit / negative
  debit).
- **All other allocation columns** balance out the cash impact, with the
  sum of allocations = `-cash`. The full row sums to zero.
- **Summary/balance columns** (running cash balance, running loan balance,
  running syndic balance) are written only when known — they are not part
  of the balance check.

Rules for tricky cases:
- **Rent with charge provision**: split between `Rent` and `Charges`
  columns. Both negative; their sum = `-cash credit`.
- **Loan payment**: cash negative, `Capital` + `Interest` positive, with the
  decomposition taken from the loan amortization statement.
- **Syndic fund call** (non-bank line): cash empty, `Syndic` negative,
  `Charges` (or `Works`) positive — net zero, no cash impact.
- **Regularization** (refunded bank fee, credited interest): opposite sign
  on the same columns as the original entry.

### 4. Code in Python, validate at construction

Build the CSV with a small Python script, not by hand. Centralize the row
constructor:

```python
def L(date, memo, **moves):
    row = {col: "" for col in COLS}
    # "Zero" is an example control column that must read 0 on a balanced row;
    # rename or drop it to match your ledger's actual columns.
    row["Date"], row["Memo"], row["Zero"] = date, memo, 0.0
    total = 0.0
    for short, val in moves.items():
        if short in ("balance", "loan_balance", "syndic_balance"):
            continue
        row[KEY[short]] = val
        total += val
    if abs(total) > 0.001:
        raise ValueError(f"Row does not balance: {date} {memo} total={total}")
    # ... fill summary columns from kwargs ...
    return row
```

The validation at construction time catches misclassifications immediately,
when they are still easy to debug.

### 5. Three mandatory verifications

Before delivering the CSV, all three must pass:

1. **Cumulative cash check** — opening balance + sum of cash column =
   closing balance per the last statement. Should match to the cent.
2. **Monthly balance check** — reconstruct the cash balance at the end of
   each month and compare to the `NOUVEAU SOLDE AU JJ/MM` line of each
   monthly statement. Any divergence isolates a specific month to
   investigate.
3. **Non-cash account year-end balances** — syndic, loan, etc.: closing
   balance per the auxiliary document = closing balance per the CSV.

If any check fails, do not deliver. Fix first.

### 6. Output format

- Comma-separated CSV
- Period as decimal separator
- Minus sign for negatives, no thousands separator (unless the reference
  CSV uses a specific accounting format — match it)
- Truly empty cells for formula-driven columns (e.g., `Solde`, `Capital
  restant dû` if calculated from a running sum); do not write zero
- Two header rows: table title in row 1, column names in row 2

### 7. Annotate unknowns explicitly

For any bank entry whose classification is uncertain, create the row with
a plausible best-guess allocation **and prefix the memo with
`[TO CLASSIFY]`**. The row still balances; the CSV is usable; a `grep`
on the prefix lists everything to validate.

Never leave unclassified bank movements out of the CSV — that would break
the cumulative cash check.

### 8. Iterate, do not rewrite

The first draft is never final (mis-guessed rent split, cheque mis-attributed
between two syndics, late column addition). Structure the Python script so
that a correction is a minimal change — a constant edit, a key rename, a
single `if`/`else` adjustment — and regenerate. Do not rewrite end-to-end
on each round.

## Output

A single CSV file delivered via `present_files`. Accompany with:
- One-line confirmation that all three verifications passed
- The list of `[TO CLASSIFY]` rows (if any) for user validation
- Explicit listing of any assumptions taken (rent decomposition, cheque
  attribution, etc.)

## What /bookkeeping does not do

- Does not produce input for accounting software (QuickBooks, Sage, etc.)
- Does not file taxes
- Does not generate financial statements (balance sheet, P&L) — only the
  raw ledger
- Does not handle the transition between two years (closing entries,
  reversal entries) — that is a separate workflow
