# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**Shuby** is a mobile-first web app for parents to track child development from 0 to 36 months. It covers growth measurements (WHO percentile standards), developmental milestone questionnaires across 5 areas, AI-powered parenting guidance, and pediatrician-ready reports. All UI is in **Italian**. Target: Q2 2026 soft launch.

Built on **Jumpstart Pro Rails 8** — a multi-tenant SaaS starter that provides authentication (Devise), authorization (Pundit), subscription billing (Pay gem), team/account management, and Hotwire (Turbo + Stimulus).

## Shuby Domain

### Core Concepts
- **Children** (0-36 months): each belongs to an Account, supports corrected age for premature babies
- **Measurements**: weight (kg), height (cm), head circumference (cm) — plotted against WHO percentile standards
- **Questionnaires**: developmental assessments across 5 areas (motor, cognitive, language, social-emotional, adaptive)
- **Growth phases**: timeline navigation through developmental stages
- **Archive**: content library with articles and resources
- **AI-Helper (Shuby Chat)**: conversational assistant powered by RubyLLM + OpenAI

### AI Chat Architecture
- **RubyLLM** (`~> 1.2`) with `acts_as_chat` models
- **OpenAI Vector Store** for RAG (Retrieval Augmented Generation)
- **FileSearchTool**: custom tool that searches the hosted Vector Store
- **Turbo Streams** for real-time message streaming
- Default model: `gpt-5-mini` (configurable in `ShubyAssistantService::DEFAULT_MODEL`)

### Key Shuby Files

```
app/models/child.rb                        # Child profile model
app/models/measurement.rb                  # Growth measurements (WHO standards)
app/models/questionnaire*.rb               # Developmental questionnaires
app/models/archive_content.rb              # Content library
app/models/shuby_chat.rb                   # AI chat model (acts_as_chat)
app/models/shuby_message.rb                # Chat message (acts_as_message)
app/models/shuby_tool_call.rb              # Tool call (acts_as_tool_call)
app/controllers/children_controller.rb     # Child CRUD
app/controllers/measurements_controller.rb # Measurement tracking
app/controllers/shuby_chats_controller.rb  # AI chat interface
app/services/shuby_assistant_service.rb    # AI system prompt & config
app/tools/file_search_tool.rb              # Vector Store search tool
config/routes/shuby.rb                     # Shuby routes
config/initializers/ruby_llm.rb            # RubyLLM configuration
```

### Specification Documents
- **Product spec**: `docs/Shuby 1.0 - Specifiche di Prodotto.md` (Italian)
- **Functional analysis**: `docs/Shuby - Analisi Funzionale - v.1.0.pdf` (Italian)
- Always verify implementations against these documents

### OpenAI Credentials

Required in `bin/rails credentials:edit`:

```yaml
openai:
  api_key: sk-your-api-key
  vector_store_id: vs_your-vector-store-id
```

## Technology Stack

- **Rails 8** with Hotwire (Turbo + Stimulus) and Hotwire Native
- **PostgreSQL** (primary), **SolidQueue** (jobs), **SolidCache** (cache), **SolidCable** (websockets)
- **Import Maps** for JavaScript (no Node.js dependency)
- **TailwindCSS v4** via tailwindcss-rails gem
- **Devise** for authentication with custom extensions
- **Pundit** for authorization
- **RubyLLM** for AI chat with OpenAI
- **Minitest** for testing with parallel execution

## Architecture (Jumpstart Pro Foundation)

### Multi-tenancy
- **Account-based tenancy**: Users belong to Accounts (personal or team)
- **AccountUser**: join table with roles
- **current_account**: always available in controllers/views — scope all queries through it
- **switch_account(account)**: for switching context (and in tests)

### Modular Models

Models use Ruby modules for organization:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include Accounts, Agreements, Authenticatable, Mentions, Notifiable, Searchable, Theme
end

# app/models/account.rb
class Account < ApplicationRecord
  include Billing, Domains, Transfer, Types
end
```

### Billing & Payments
- **Pay gem (~11.0)**: Stripe, Paddle, Braintree, PayPal, Lemon Squeezy
- **Subscription management**: `app/models/account/billing.rb`
- **Feature gating**: `Jumpstart.config.payments_enabled?`
- **Jumpstart config**: `config/jumpstart.yml` controls enabled features

### Routes

Modularized in `config/routes/`:
- `shuby.rb` - AI chat routes (`/shuby`)
- `accounts.rb` - Account management, switching, invitations
- `billing.rb` - Subscription, payment, receipt routes
- `users.rb` - User profile, settings, authentication
- `api.rb` - API v1 endpoints with JWT authentication

### Key Directories

- `app/controllers/accounts/` - Account-scoped controllers
- `app/models/concerns/` - Shared model modules
- `app/policies/` - Pundit authorization policies
- `app/components/` - View components for reusable UI
- `lib/jumpstart/` - Core Jumpstart engine and configuration

## Development Commands

```bash
bin/setup                    # Initial setup
bin/dev                      # Dev server with Overmind (Rails + asset watching)
bin/rails db:migrate         # Run migrations
bin/rails test               # Run test suite (Minitest)
bin/rails test:system        # System tests (Capybara + Selenium)
bin/rubocop                  # RuboCop linter
bin/rubocop -a               # Auto-fix RuboCop issues
bin/jobs                     # Start SolidQueue worker
```

## Testing

- **Minitest** with fixtures in `test/fixtures/`
- **System tests**: Capybara with Selenium WebDriver
- **Test parallelization**: `parallelize(workers: :number_of_processors)`
- **WebMock**: external HTTP requests disabled — stub all external APIs
- **Multi-tenancy in tests**: use `switch_account(account)` for tenant context

## Development Workflow

### Session Start
Run `/shuby-status` to see current progress, or `/shuby-next` to pick up the next task.
The SessionStart hook automatically loads the last session's handoff context.

### Feature Development Priority (v1.0 Remaining)
See `docs/PROGRESS.md` for the current checklist. Priority order:
1. Growth chart visualizations
2. Pediatrician report PDF generation
3. Premium feature gating
4. Notification system
5. Advanced analytics
6. Test coverage & technical debt

### Quality Gates (Automated)
- **Auto-RuboCop**: Ruby files are auto-formatted after every edit
- **Stop reminder**: If you modified .rb files, you'll be reminded to run tests
- **Spec review**: Run `/shuby-review` to verify against product spec

### Code Composition Standards
All code must follow `.claude/rules/code-composition.md`:
- **Views < 200 lines** — decompose into partials + helpers
- **No copy-paste** — 3+ repetitions = extract a helper
- **Data-driven rendering** — define data as constants, loop to render
- **Reuse existing patterns** — `render_svg`, `badge()`, partials

### Before Committing
1. `/shuby-test` — run tests and RuboCop
2. `/shuby-review` — check spec compliance
3. Use `/commit` to create a well-formatted commit

### Session End
Run `/shuby-handoff` to save context for the next developer. This writes to `.claude/HANDOFF.md` and updates `docs/PROGRESS.md`.

### For New Team Members
1. Read this CLAUDE.md
2. Read `docs/Shuby 1.0 - Specifiche di Prodotto.md` for product context
3. Run `/shuby-status` to understand current state
4. Expected project permissions (for `.claude/settings.local.json`):
   - `bin/rails test`, `bin/rubocop`, `bundle exec`, `bin/rails generate/db:migrate`
   - `git add/commit/log/diff/status/stash/branch`
   - Playwright and Figma MCP tools
