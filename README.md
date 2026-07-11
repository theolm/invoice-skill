# Invoice Skill

Generate professional invoice PDFs via AI agents. Compatible with any agent
supporting the Agent Skills standard (OpenCode, Claude Code, Codex, Cursor,
and 70+ more).


## Installing

### Using npx skills (recommended)

Requires Node.js. Installs to all detected agents automatically.

```bash
# Install globally (available in any project)
npx skills add https://github.com/theolm/invoice-skill -g

# Install in current project only
npx skills add https://github.com/theolm/invoice-skill
```

## Updating

The skill is distributed via Git. Run one of the commands below to pull the latest version:

```bash
# Update the global install
npx skills update invoice-pdf -g

# Update the project install
npx skills update invoice-pdf
```

## Usage

After installing the skill, just ask your AI agent in natural language.

### Creating an invoice

```
Generate an invoice for Ambush — Development work, 5 hours at $150/hour.
```

The agent will collect any missing info (company details on first use, issue date,
due date, etc.) and generate the PDF.

### Reusing previous data

```
Generate another invoice for the same client with the same service.
```

The agent remembers the last client and service, so you can skip re-entering
everything.

### Changing dates

```
Generate an invoice for tomorrow with 30-day payment terms.
```

The agent will ask if you want to confirm or adjust the dates.

### Customizing data

The agent manages your company info, client list, and preferences across
sessions. To update any of them:

```
Update my company address to the new office downtown.
```

### Output

Generated PDFs are saved to `invoices/invoice-{id}-{YYYY-MM-DD}.pdf` in your
project root.

See the [invoice schema](invoice-pdf/schema/invoice_schema.json) for all
available fields.

## Persistence

The AI agent manages state across sessions via JSON files in `.invoice-skill/`:

| File | Content |
|------|---------|
| `company.json` | Company info + bank details (asked once) |
| `clients.json` | List of past clients (optional, grows over time) |
| `counter.json` | Auto-incrementing invoice ID |
| `preferences.json` | Default currency, etc. |
| `last_service.json` | Last service used (reused on next invoice if desired) |

Generated PDFs go to `invoices/` with unique names: `invoice-{id}-{YYYY-MM-DD}.pdf`.