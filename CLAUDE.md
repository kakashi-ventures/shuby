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
- **Product decisions**: `docs/DECISIONS.md` (client decisions that override the spec)
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
- **Ruby Native v0.7** for iOS App Store deployment (rubynative.com)
- **PostgreSQL** (primary), **SolidQueue** (jobs), **SolidCache** (cache), **SolidCable** (websockets)
- **Import Maps** for JavaScript (no Node.js dependency)
- **TailwindCSS v4** via tailwindcss-rails gem
- **Devise** for authentication with custom extensions
- **Pundit** for authorization
- **RubyLLM** for AI chat with OpenAI
- **Minitest** for testing with parallel execution

## Ruby Native (iOS App)

Shuby is deployed as a native iOS app via **Ruby Native** (rubynative.com, app.shuby.rubynative). The gem `ruby_native` (~> 0.7) wraps the Rails web app in a native iOS shell with native tab bar, haptics, badges, and safe area handling.

### CRITICAL: Web must not break
All native-specific CSS must be scoped to `html.hotwire-native`. This class is only present when running inside the iOS shell. Never add native-only styles without this selector. The `env(safe-area-inset-*)` values resolve to `0px` in browsers — safe to use unconditionally but always scope behavior changes.

### Key files
```
config/ruby_native.yml                     # Tabs, appearance, mode config
app/assets/tailwind/components/hotwire_native.css  # iOS safe area insets + bridge CSS
app/views/layouts/application.html.erb     # native_tabs_tag, native_badge_tag, native-inset-top
```

### Design decisions (from Figma analysis)
- **NO `native_navbar_tag`** — all pages use custom web headers matching the Figma design
- **Native iOS tab bar** replaces the web bottom nav (`_shuby_bottom_nav.html.erb` is hidden via CSS in native)
- **Custom headers preserved as-is** — Dashboard "Ciao [nome] e [bambino]", Archivio filters, etc.

### Rules for new views
- **Form pages**: add `<%= native_form_tag %>` as the first line (signals back-stack skip after submit)
- **Submit buttons**: add `data: native_haptic_data(:success)` for haptic feedback
- **Safe area**: if adding a new sticky/fixed header, add `padding-top: env(safe-area-inset-top)` scoped to `html.hotwire-native` in `hotwire_native.css`
- **Tab routing**: child-related paths (`/children/*`) auto-switch to the Oggi tab. See `auto_route` in `ruby_native.yml`

### Coexistence with Jumpstart Hotwire Native
- Jumpstart's bridge controllers (`bridge--form`, `bridge--sign-out`, etc.) do NOT load in Ruby Native — the `shouldLoad` mechanism in `@hotwired/hotwire-native-bridge` checks User-Agent and finds no registered components
- `hotwire_native_app?` returns `true` in the Ruby Native shell — all existing conditionals work
- Do NOT replace `hotwire_native_app?` with `native_app?` — both work, avoid regressions
- The `/today` route is a dedicated path for the iOS Oggi tab (avoids root `/` ambiguity)

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

### Remaining Work & Progress

- **Current state**: Run `/shuby-audit` to get a code-vs-specs gap analysis (source of truth)
- **Progress tracking**: `docs/REMAINING-WORK.md` — maintained by `/shuby-audit` and `/shuby-handoff`
- **Subscription plan**: `docs/SHUBY PIANO DI ABBONAMENTO.pdf` — definitive free/premium matrix
- **Pending decisions**: See `docs/DECISIONS.md` entries with status `to-confirm` (file may be partially outdated)
- `docs/PROGRESS.md` has been removed — use `docs/REMAINING-WORK.md` instead

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
Run `/shuby-handoff` to save context for the next developer. This writes to `.claude/HANDOFF.md` and updates `docs/REMAINING-WORK.md`.

### For New Team Members
1. Read this CLAUDE.md
2. Read `docs/Shuby 1.0 - Specifiche di Prodotto.md` for product context
3. Run `/shuby-audit` to understand current state vs specs
4. Run `/shuby-status` for session context
5. Expected project permissions (for `.claude/settings.local.json`):
   - `bin/rails test`, `bin/rubocop`, `bundle exec`, `bin/rails generate/db:migrate`
   - `git add/commit/log/diff/status/stash/branch`
   - Playwright CLI, Figma MCP, Render MCP tools

## Document Hierarchy (conflict resolution)

1. **DECISIONS.md** — client meeting overrides (highest priority)
2. **SHUBY PIANO DI ABBONAMENTO.pdf** — definitive free/premium feature matrix
3. **Analisi Funzionale PDF** — screen-by-screen behavior details
4. **Specifiche di Prodotto.md** — product-level requirements
5. **Figma design** — visual source of truth for all UI
6. **The codebase** — determines actual state (generated docs may be stale)

When documents conflict: follow the hierarchy. When something is TBD in all docs, use Italian UX best practices and flag the decision in the commit message.

## Figma Design (Visual Source of Truth)

- **Main file**: https://www.figma.com/design/qriF7HfsvoG8VUSdjUETBd/Shuby_App (fileKey: `qriF7HfsvoG8VUSdjUETBd`)
- **MANDATORY**: Before modifying ANY screen, check the Figma design first
- **MANDATORY**: After UI changes, verify with Playwright CLI screenshot (mobile 390x844) + Figma comparison
- Use `/shuby-figma-check [section]` for systematic visual comparison
- When Figma conflicts with FA/PRD on visual details, Figma wins

### Figma Tools
- **Figma MCP**: `get_design_context` (code + screenshot + hints), `get_screenshot` (visual), `get_metadata` (structure)
- **Playwright CLI**: `playwright-cli screenshot` for local app screenshots (more efficient than Playwright MCP)
- The Figma file is large and complex. Always use `get_metadata` first to navigate to the right nodeId, then `get_design_context` on the specific node.

### Figma Node Map (main screens)

| Screen | Figma nodeId | Figma Name |
|--------|-------------|------------|
| Dashboard (blue header) | `375:5429` | 01.01_Hero/Azzurra |
| Dashboard (white header) | `434:12577` | 01.01_Hero/Bianca |
| Dashboard variant 2 | `499:6713` | 01.03_Hero/Azzurra 2 |
| Timeline (current) | `211:2608` | 02.01_Timeline |
| Timeline (past) | `322:7818` | 02.02_Timeline_Passato |
| Timeline (future) | `322:8041` | 02.03_Timeline_Futuro |
| Child profile - Info | `434:13573` | 03.01_Scheda bambino_Info |
| Child profile - Measurements 1 | `436:4638` | 03.02_Scheda bambino_Misurazioni_01 |
| Child profile - Measurements 2 | `451:5043` | 03.03_Scheda bambino_Misurazioni_02 |
| Child profile - Stages 1 | `451:5546` | 03.04_Scheda bambino_Tappe/01 |
| Child profile - Stages 2 | `541:7850` | 03.04_Scheda bambino_Tappe/02 |
| AI Helper | `463:5386` | 04.01_AI_helper |
| Archive | `463:6063` | 05.01_Archivio |
| Article detail | `510:22491` | 05.02_Articolo |
| Activity detail | `532:24578` | 05.03_Attività |
| Game detail | `532:25861` | 05.04_Gioco |
| Book detail | `532:26226` | 05.05_Libro |
| Settings/Account | `455:5017` | 06.01_Gestione |
| Add measurement overlay | `621:9860` | 00.05_Overlay_Aggiungi Altezza |

### Figma Components (design system)
Colors section, Typography section, plus: Header (`379:5503`), Button (`65:38`), Timeline (`322:6922`), Cards (Scheda Test `413:3498`, Scheda Attività `413:3570`, Scheda Misurazioni `413:3671`, Scheda Consigli `413:3942`), Tab (`436:4918`), Form (`220:2532`), Chat (`230:1824`), Child selector (`220:2341`), Menu (`198:3262`).

## Pending Decisions (need client confirmation)

| ID | Question | Current Approach |
|----|----------|-----------------|
| DEC-005 | AI chat free limit: 8 dom/mese (PDF) vs 10 (PRD) vs 30 (meeting) | **Implement PDF version (8/mese o 1/giorno) — most recent** |
| DEC-012 | Stage proposal: AI-driven vs sequential | Sequential for v1.0, flag for future |
| DEC-015 | Content: all generic free (PDF) vs 20 free (PRD) | **Implement PDF version** |
| DEC-017 | Launch language: IT only vs IT+EN+FR | IT only, translations as bonus if ready |

**Rule**: For to-confirm decisions, implement the most recent document version (PDF > meeting > PRD) but keep limits configurable.
