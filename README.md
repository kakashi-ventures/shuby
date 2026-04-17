# Shuby

Shuby is a mobile-first web application for parents tracking their child's development from 0 to 36 months. The UI is in Italian. Target launch: Q2 2026. Shipped both as a web app and as a native iOS app (App Store) via Ruby Native.

## What Shuby does

- Growth measurements against WHO percentile standards (weight, height/length, head circumference, feeding weight)
- Developmental questionnaires across 5 areas (motor, cognitive, language, social-emotional, adaptive) with a 14-day edit window
- Development timeline 0–36 months with phases, milestones, and activities
- **Shuby Chat** — conversational AI assistant with RAG over a pediatric knowledge base (OpenAI Vector Store)
- Pediatrician-ready PDF reports (generated with Prawn)
- Content archive (articles, tips, activities) filtered by age
- Multi-child support and family profile
- Freemium model (free / premium via the Pay gem — Stripe)

## Tech stack

- **Ruby 4.0.2** · **Rails 8.1**
- **Hotwire** (Turbo + Stimulus) with **Import Maps** (no Node/npm)
- **TailwindCSS v4** via `tailwindcss-rails`
- **PostgreSQL** + **SolidQueue** / **SolidCache** / **SolidCable**
- **Ruby Native v0.7** — native iOS shell wrapping the Rails app ([rubynative.com](https://rubynative.com))
- **RubyLLM 1.2** + **ruby-openai** (Vector Store RAG, default model `gpt-5-mini`)
- **Prawn** + **prawn-table** for pediatrician PDF reports
- **Devise** (auth), **Pundit** (authz), **Pay** (billing)
- **Minitest** + Capybara/Selenium for system tests; **RuboCop** (omakase)

## Requirements

- Ruby 4.0.2 (see `.ruby-version`)
- PostgreSQL 12+
- libvips or ImageMagick
- (Optional) [Stripe CLI](https://docs.stripe.com/stripe-cli) to sync webhooks in development

## Initial setup

```bash
bin/setup
bin/rails credentials:edit
```

Add OpenAI credentials (required for Shuby Chat):

```yaml
openai:
  api_key: sk-your-api-key
  vector_store_id: vs_your-vector-store-id
```

See `docs/shuby_setup.md` for the full AI setup guide.

## Local development

```bash
bin/dev                      # Overmind: Rails + Tailwind watch + jobs
```

If Overmind is unavailable, run the processes individually:

```bash
bin/rails db:migrate         # run first — pending migrations cause 500s
bin/rails db:seed            # seeds questionnaires, phases, archive content
bin/rails server -p 3000     # use -p 3001 if 3000 is busy
bin/rails tailwindcss:watch  # separate terminal
bin/jobs                     # SolidQueue worker, separate terminal
```

### Demo accounts

The app ships with pre-populated demo accounts (see `docs/DEMO.md`):

| Email              | Password   | Plan    | Notes                              |
|--------------------|------------|---------|------------------------------------|
| `maria@demo.shuby` | `testtest` | free    | Full family, 3 children, rich data |
| `luca@demo.shuby`  | `testtest` | premium | 1 child, minimal data              |

### Bootstrap a fresh admin user

On an empty database, create a test admin with:

```bash
bin/rails runner '
user = User.create!(
  name: "Admin Test",
  email: "admin@test.com",
  password: "password123",
  password_confirmation: "password123",
  terms_of_service: true,
  confirmed_at: Time.current
)
Jumpstart.grant_system_admin!(user)
account = user.accounts.first
account.children.create!(
  name: "Marco",
  birth_date: 6.months.ago.to_date,
  sex: "male",
  active: true
)
puts "Done: admin@test.com / password123"
'
```

| Field    | Value           |
|----------|-----------------|
| Email    | admin@test.com  |
| Password | password123     |
| Role     | System admin    |
| Child    | Marco (~6 mesi) |

## iOS app (Ruby Native)

Shuby ships to the App Store as `app.shuby.rubynative` through [Ruby Native](https://rubynative.com), which wraps the web app in a native iOS shell with a native tab bar, haptics, and safe-area handling. Tabs and appearance are configured in `config/ruby_native.yml`.

**Critical rule:** all native-only CSS must be scoped under `html.hotwire-native` so the web experience is not affected. See `.claude/rules/ruby-native-ios.md` for the full iOS guidelines (forms, haptic data, auto-routing, navbar handling).

## Testing & quality gates

```bash
bin/rails test
bin/rails test:system
bin/rubocop
bin/rubocop -a               # auto-fix
```

UI screenshots and visual regression: Playwright CLI (`.claude/skills/playwright-cli/`), mobile viewport 390×844. Compare against Figma via `/shuby-figma-check`.

## Documentation

Primary references:

- [`CLAUDE.md`](CLAUDE.md) — Claude Code guidance and project conventions
- [`docs/Shuby 1.0 - Specifiche di Prodotto.md`](docs/Shuby%201.0%20-%20Specifiche%20di%20Prodotto.md) — product spec (IT)
- `docs/Shuby - Analisi Funzionale - v.1.0.pdf` — screen-by-screen functional analysis (IT)
- [`docs/DECISIONS.md`](docs/DECISIONS.md) — client decisions that override the spec
- `docs/SHUBY PIANO DI ABBONAMENTO.pdf` — definitive free/premium matrix
- [`docs/REMAINING-WORK.md`](docs/REMAINING-WORK.md) — active backlog
- [`docs/DEVELOPMENT-STATUS.md`](docs/DEVELOPMENT-STATUS.md) — feature-by-feature implementation status
- [`docs/FIGMA-REFERENCE.md`](docs/FIGMA-REFERENCE.md) — Figma node map and workflow
- [`docs/shuby-design-system.md`](docs/shuby-design-system.md) — design system
- [`docs/shuby_setup.md`](docs/shuby_setup.md) — AI chat setup
- [`docs/DEMO.md`](docs/DEMO.md) — demo accounts

Slash commands and rules for Claude-assisted development:

- `.claude/commands/shuby-*.md` — `/shuby-audit`, `/shuby-next`, `/shuby-review`, `/shuby-figma-check`, `/shuby-premium`, `/shuby-test`, `/shuby-handoff`, `/shuby-status`
- `.claude/rules/` — conventions for views, controllers, models, code composition, Ruby Native iOS, Figma alignment, and premium gating

## Development workflow

Typical session:

1. `/shuby-status` (or `/shuby-next`) — see progress, pick up work
2. Implement the change
3. `/shuby-test` — run tests + RuboCop
4. `/shuby-review` — verify against product spec
5. `/commit` — create a well-formatted commit
6. `/shuby-handoff` — save context for the next session

Full details in [`CLAUDE.md`](CLAUDE.md) under "Development Workflow".

## Foundation & upstream sync

Shuby is built on top of **Jumpstart Pro Rails 8** ([jumpstartrails.com](https://jumpstartrails.com)), a multi-tenant SaaS starter that provides: Devise + OAuth, Pundit, accounts/teams, Pay (Stripe, Paddle, Braintree, PayPal, Lemon Squeezy), invitations, admin, notifications, and inbound webhooks.

To pull upstream updates from Jumpstart Pro, make sure the remote is configured:

```bash
git remote add jumpstart-pro \
  https://github.com/jumpstart-pro/jumpstart-pro-rails.git
```

Then fetch and merge when a new Jumpstart release drops:

```bash
git fetch jumpstart-pro
git merge jumpstart-pro/main
```

Jumpstart-specific upgrade notes relevant to Shuby are tracked in [`UPGRADE.md`](UPGRADE.md).

## Contributing

Internal project. Follow the workflow in [`CLAUDE.md`](CLAUDE.md); open a PR only after `/shuby-test` and `/shuby-review` pass.
