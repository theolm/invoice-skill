# Invoice Skill

Generate professional invoice PDFs via AI models (Claude, Hermes, GPT, etc.).

## Structure

```
├── .invoice-skill/     ← persisted state (company, clients, counter, preferences)
├── invoices/           ← generated PDFs (invoice-{id}-{YYYY-MM-DD}.pdf)
├── skill/              ← opencode skill files (loaded by the AI agent)
│   ├── SKILL.md        ← instructions for the AI model
│   ├── schema/         ← JSON schema of invoice fields
│   └── references/     ← detailed field documentation
├── generator/          ← Dart project that generates the PDF
│   ├── bin/            ← CLI entry point + compiled binary
│   └── lib/            ← Dart source code
├── examples/           ← sample input
└── README.md
```

## Persistence

The AI agent manages state across sessions via JSON files in `.invoice-skill/`:

| File | Content |
|------|---------|
| `company.json` | Company info + bank details (asked once) |
| `clients.json` | List of past clients (optional) |
| `counter.json` | Auto-incrementing invoice ID |
| `preferences.json` | Default currency, etc. |

Generated PDFs go to `invoices/` with unique names: `invoice-{id}-{YYYY-MM-DD}.pdf`.

## Building the Generator

```bash
cd generator && chmod +x build.sh && ./build.sh
```

## Usage

```bash
# Using compiled binary
./skill/bin/generate_invoice --data='{...}' --output=invoices/invoice-1001-2026-07-10.pdf

# Using Dart directly
cd generator && dart run bin/generate_invoice.dart \
  --file ../examples/input.json \
  --output ../invoices/invoice-1001-2026-07-10.pdf

# Auto-naming (CLI generates filename from data)
cd generator && dart run bin/generate_invoice.dart \
  --file ../examples/input.json \
  --auto-name \
  --output-dir ../invoices
```

## Installing as an opencode Skill

Add to `~/.config/opencode/opencode.jsonc`:

```jsonc
{
  "skills": {
    "paths": ["/path/to/invoice-skill/skill"]
  }
}
```
