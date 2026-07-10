# Field Guide - Invoice Data

Detailed descriptions of each invoice field for the AI model.

## Top-level fields

- `id` (int): Unique invoice number. Auto-incremented in `.invoice-skill/counter.json`.
- `issueDate` (int): Date the invoice was issued, as milliseconds since Unix epoch.
- `dueDate` (int): Date payment is due, as milliseconds since Unix epoch.
- `createdAt` (int, optional): Record creation timestamp.
- `updatedAt` (int, optional): Record last update timestamp.

## ServiceInfo

- `description` (string): What was provided/sold.
- `quantity` (double): Number of units/hours.
- `price` (double): Price per unit.
- `currency` (object, default from `preferences.json`): `{ name, cc, symbol }`.

## CompanyInfo (emitter)

Persisted in `.invoice-skill/company.json`. Rarely changes.

- `name` (string): Legal company name.
- `email` (string): Contact email.
- `ownerName` (string): Owner/representative full name.
- `cnpj` (string, optional): Brazilian CNPJ.
- `address` (Address, optional): Company physical address.
  - `street`, `extraInfo`, `neighbourhood`, `city`, `state`, `country`, `zipCode`

## ClientInfo (recipient)

Optionally saved to `.invoice-skill/clients.json` after generation.

- `name` (string): Client name.
- `address` (string): Full address text.

## BankInfo

Persisted in `.invoice-skill/company.json` alongside CompanyInfo.

- `beneficiaryName` (string): Name on bank account.
- `main` (Bank): Primary bank account.
  - `iban`, `swift`, `bankName`, `bankAddress`
- `intermediary` (Bank, optional): Intermediary bank.
  - `iban`, `swift`, `bankName`, `bankAddress`

## State File Locations

All files live at the project root:

```
.invoice-skill/
├── company.json       ← CompanyInfo + BankInfo
├── clients.json       ← [{ name, address, usedCount, lastUsed }]
├── counter.json       ← { last_id: int }
└── preferences.json   ← { currency: { name, cc, symbol } }

invoices/
└── invoice-{id}-{YYYY-MM-DD}.pdf
```
