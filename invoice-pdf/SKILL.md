---
name: invoice-pdf
description: >
  Generate professional invoice PDFs for the company's standard format.
  Manages persistent user data (company info, client list, invoice counter,
  preferences) across sessions via JSON files in .invoice-skill/ at the
  project root.
metadata:
  version: "0.1.0"
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

## Skill Directory Resolution

The binary is at `<skill_dir>/bin/generate_invoice`. Resolve `<skill_dir>` by
trying in order:

1. If the agent knows its skill directory: use that path directly.
2. **Fallback — search via shell**:
   ```bash
   find . -path "*/bin/generate_invoice" -type f 2>/dev/null | head -1
   ```
3. **Last resort**: ask the user to provide the absolute path to
   `generate_invoice`.

## First-Time Setup

Run once per installation:

```bash
chmod +x <path_to>/bin/generate_invoice
```

If this fails (e.g., read-only filesystem), copy the binary to a writable
location:

```bash
mkdir -p ./.invoice-skill/bin
cp <path_to>/bin/generate_invoice ./.invoice-skill/bin/generate_invoice
chmod +x ./.invoice-skill/bin/generate_invoice
```

## Workflow

**Important: always ask one question at a time. Never ask multiple questions
in a single response. When a default exists, include it in the question.**

### First Run (no state files exist)

1. Resolve `<skill_dir>` (see Skill Directory Resolution above)
1. Run first-time setup (see First-Time Setup above)
1. `mkdir -p .invoice-skill`
1. **Collect company info** — one field at a time:
   - "Company name?"
   - "Owner name?"
   - "Email?"
   - "CNPJ?" (optional — skip if not applicable)
   - "Street and number?"
   - "Complement?" (optional)
   - "Neighbourhood?"
   - "City?"
   - "State?"
   - "Country?"
   - "Zip code?"
1. **Collect bank info** — one field at a time:
   - "Beneficiary name?"
   - "IBAN?"
   - "SWIFT/BIC?"
   - "Bank name?"
   - "Bank address?"
1. Write `.invoice-skill/company.json` with CompanyInfo + BankInfo
1. "Starting invoice ID?" — ask once, write to `counter.json`
1. "Default currency?" — if not provided, default: **USD ($)**
1. **Collect client** — one field at a time:
   - "Client name?"
   - "Client address?"
1. **Collect service** — one field at a time:
   - "Service description?"
   - "Quantity?"
   - "Unit price?"
1. **Issue date:** "Issue date: today (YYYY-MM-DD) — OK or different?"
   If different, ask for the date.
1. **Due date:** "Due date: 15 business days from issue date (YYYY-MM-DD) — OK or different?"
   If different, ask for the date.
1. **Convert dates to UTC midnight, then to milliseconds since Unix epoch** before passing to the binary:
   - macOS: `date -u -j -f "%Y-%m-%d" "2026-07-11" +%s` → multiply the result by 1000
   - Linux: `date -u -d "2026-07-11" +%s%3N`
   - The `-u` flag forces UTC so the date stays exactly what the user said, regardless of the machine's timezone.
1. Generate PDF: `<skill_dir>/bin/generate_invoice --data='{...}' --auto-name --output-dir=invoices`
1. Save service to `.invoice-skill/last_service.json`
1. "Save this client for next time?" — if yes, append to `.invoice-skill/clients.json`
1. Increment `.invoice-skill/counter.json`

### Subsequent Runs

Saved data found in `.invoice-skill/`. Load everything, present a single
summary, and ask:

```
"I have:
 Company: {company.name}
 Client: {client.name} ({client.address})
 Service: {service.description} ({service.quantity} x {service.currency.symbol}{service.price})
 Invoice #{next_id}
 Issue date: today (YYYY-MM-DD)
 Due date: 15 business days from issue date (YYYY-MM-DD)

 Generate or change something?"
```

- If **generate** → skip all questions, proceed to step 5.
- If **change X** → ask only about that field (one question at a time).
  Keep everything else from saved data.

1. Resolve `<skill_dir>` (see Skill Directory Resolution above)
1. Read all `.invoice-skill/` files
1. Present summary → user chooses generate or change
1. If changing client: check `.invoice-skill/clients.json` first —
   "Use Ambush (used 3x) or new client?"
1. If changing service: check `.invoice-skill/last_service.json` —
   "Use last service ({description}, {qty} x {price}) or new?"
1. If changing issue date: "Issue date: today (YYYY-MM-DD) — OK or different?"
1. If changing due date: "Due date: 15 business days from issue date (YYYY-MM-DD) — OK or different?"
1. **Convert dates to UTC midnight, then to milliseconds since Unix epoch** (see conversion instructions in First Run above)
1. Generate PDF using `<skill_dir>/bin/generate_invoice`
1. Save service to `.invoice-skill/last_service.json`
1. Update client in `.invoice-skill/clients.json` (increment usedCount)
1. Increment `.invoice-skill/counter.json`

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

The compiled binary is at `<skill_dir>/bin/generate_invoice`. See Skill
Directory Resolution and First-Time Setup above for locating and preparing
the binary. It runs standalone — no Dart SDK needed.

Run the binary with invoice data:

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
