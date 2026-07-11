---
name: invoice-pdf
description: >
  Generate professional invoice PDFs for the company's standard format.
  Manages persistent user data (company info, client list, invoice counter,
  preferences) across sessions via JSON files in .invoice-skill/ at the
  project root.
---

# Invoice PDF Generator

## When to Use

- User asks to create an invoice, nota fiscal, or receipt
- User asks to generate a billing document
- User provides invoice data or asks the agent to collect it

## When NOT to Use

- User asks about existing invoices (use the app instead)
- User wants to edit a PDF that already exists
- General PDF manipulation not related to invoices

## Persistence

State lives in `.invoice-skill/` at the project root. The agent manages these
files directly using `read`, `write`, and `bash` tools.

### File Layout

| File | Purpose | Changes |
|------|---------|---------|
| `.invoice-skill/company.json` | Emitter data (CompanyInfo + BankInfo) | Rarely |
| `.invoice-skill/clients.json` | List of past clients | Optional, grows over time |
| `.invoice-skill/counter.json` | `{ "last_id": 1001 }` | Every invoice (auto-increment) |
| `.invoice-skill/preferences.json` | Default currency, etc. | Rarely |
| `.invoice-skill/last_service.json` | Last service used (description, quantity, price, currency) | Every invoice |

### Company Info

File: `.invoice-skill/company.json`

```json
{
  "companyInfo": { ... },
  "bankInfo": { ... }
}
```

Saved once on first use. If it exists, skip these questions entirely.

### Client List

File: `.invoice-skill/clients.json`

```json
[
  {
    "name": "GlobalClient Corp",
    "address": "456 Market St, San Francisco, CA 94105",
    "usedCount": 5,
    "lastUsed": 1754064000000
  }
]
```

After generating an invoice, ask: "Save this client for next time?" If yes,
append/update in `clients.json`. Before creating an invoice, check this list
and suggest existing clients: "GlobalClient Corp (used 5x) — use them?"

### Invoice Counter

File: `.invoice-skill/counter.json`

```json
{ "last_id": 1001 }
```

Auto-increments every invoice. On first run, ask the user for the starting ID.

### Preferences

File: `.invoice-skill/preferences.json`

```json
{ "currency": { "name": "US Dollar", "cc": "USD", "symbol": "$" } }
```

Default currency for new invoices. User can change later.

### Last Service

File: `.invoice-skill/last_service.json`

```json
{
  "description": "Software development",
  "quantity": 1,
  "price": 1000,
  "currency": { "name": "US Dollar", "cc": "USD", "symbol": "$" }
}
```

Saved after every invoice. Before creating a new invoice, check this file and
offer: "Use last service (Software development, 1 x $1000) — or change?"

## Workflow

### First Run (no state files exist)

1. Determine this skill's directory (`<skill_dir>`) — the absolute path where this `SKILL.md` is located
1. Ensure execute permission: `chmod +x <skill_dir>/bin/generate_invoice`
1. Create `.invoice-skill/` if missing: `mkdir -p .invoice-skill`
1. Collect company info from user (CompanyInfo + BankInfo) and write `.invoice-skill/company.json`
1. Collect initial invoice ID for `.invoice-skill/counter.json`
1. Collect default currency for `.invoice-skill/preferences.json`
1. Collect issue date: ask user to provide a date or use today
1. Collect due date: ask user to provide a date or use **15 business days** from issue date (default)
1. Collect service details + client for the current invoice
1. Generate PDF using `<skill_dir>/bin/generate_invoice`
1. Save service to `.invoice-skill/last_service.json`
1. Offer to save client to `.invoice-skill/clients.json`
1. Increment `.invoice-skill/counter.json`

### Subsequent Runs

1. Determine this skill's directory (`<skill_dir>`) — the absolute path where this `SKILL.md` is located
1. Ensure execute permission: `chmod +x <skill_dir>/bin/generate_invoice`
1. Read `.invoice-skill/company.json` — skip company questions
1. Read `.invoice-skill/counter.json` — auto-increment, propose: "Invoice #1002 — confirm or change?"
1. Read `.invoice-skill/preferences.json` — use default currency
1. Read `.invoice-skill/clients.json` — if clients exist, offer: "Use existing client or new one?"
1. Read `.invoice-skill/last_service.json` — if it exists, offer: "Use last service (description, qty x price) or provide new details?"
1. Collect issue date: ask user to provide a date or use today
1. Collect due date: ask user to provide a date or use **15 business days** from issue date (default)
1. Collect service details (or reuse last service) and client
1. Generate PDF using `<skill_dir>/bin/generate_invoice`
1. Save service to `.invoice-skill/last_service.json`
1. Offer to save client, increment counter

### Business Days Calculation

When applying the 15 business day default for due date:
- Count 15 calendar days skipping Saturdays and Sundays
- Use a weekday (Mon-Fri) as the start date
- If the result falls on a weekend, advance to the next Monday

Example: issue date 2026-07-10 (Fri) + 15 business days = 2026-07-31 (Fri)

### Updating Persisted Data

User can say "update my company address" or "change default currency" —
update the relevant file directly.

## Execution

The compiled binary is at `<skill_dir>/bin/generate_invoice` (where `<skill_dir>`
is the absolute path to this skill's directory — resolved by the agent from
context). It runs standalone — no Dart SDK needed.

1. Resolve `<skill_dir>` to this skill's installation directory
2. Ensure execute permission: `chmod +x <skill_dir>/bin/generate_invoice`
3. Run the binary with invoice data

### Manual output path

```bash
<skill_dir>/bin/generate_invoice \
  --data='{...}' \
  --output=invoices/invoice-1001-2026-07-10.pdf
```

### Auto-naming

```bash
<skill_dir>/bin/generate_invoice \
  --data='{...}' \
  --auto-name \
  --output-dir=invoices
# Generates: invoices/invoice-1001-2026-07-10.pdf
```

## Output

PDFs are saved to `invoices/` with the pattern `invoice-{id}-{YYYY-MM-DD}.pdf`.
Each invoice generates a unique file — no overwrites.

## Schema Reference

See `<skill_dir>/schema/invoice_schema.json` for all available fields and types.
See `<skill_dir>/references/field-guide.md` for detailed field descriptions.
