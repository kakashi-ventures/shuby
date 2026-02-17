---
paths:
  - "app/models/**/*.rb"
---

# Rails Model Conventions

## Module Organization
- Use Ruby modules for model organization, following the User/Account patterns
- Place domain-specific logic in dedicated modules (e.g., `User::Accounts`, `Account::Billing`)
- Reference `app/models/measurement.rb` and `app/models/archive_content.rb` as pattern examples

## Multi-tenancy
- Always scope queries through `current_account` — never expose cross-account data
- Use `belongs_to :account` for all tenant-scoped models
- Add account validation: `validates :account, presence: true`

## Validations & Data Integrity
- Define validations at the model level, not in controllers
- Use database-level constraints (NOT NULL, unique indexes) alongside model validations
- Prefer `presence: true` over custom blank checks

## Associations
- Use `dependent: :destroy` or `dependent: :nullify` explicitly on has_many
- Define inverse associations with `inverse_of` when Rails can't infer them

## Naming
- Use singular table names following Rails convention
- Prefix Shuby-domain models appropriately (e.g., `ShubyChat`, `Measurement`, `Child`)
