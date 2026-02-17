# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Jumpstart Pro Rails is a commercial multi-tenant SaaS starter application built with Rails 8. It provides subscription billing, team management, authentication, and modern Rails patterns for building subscription-based web applications.

## Development Commands

```bash
# Initial setup
bin/setup                    # Install dependencies and setup database

# Development server
bin/dev                      # Start development server with Overmind (includes Rails server, asset watching)
bin/rails server            # Standard Rails server only

# Database
bin/rails db:prepare         # Setup database (creates, migrates, seeds)
bin/rails db:migrate         # Run migrations
bin/rails db:seed           # Seed database

# Testing
bin/rails test              # Run test suite (Minitest)
bin/rails test:system       # Run system tests (Capybara + Selenium)

# Code quality
bin/rubocop                 # Run RuboCop linter (configured in .rubocop.yml)
bin/rubocop -a              # Auto-fix RuboCop issues

# Background jobs
bin/jobs                    # Start SolidQueue worker (if using SolidQueue)
bundle exec sidekiq         # Start Sidekiq worker (if using Sidekiq)
```

## Architecture

### Multi-tenancy System
- **Account-based tenancy**: Users belong to Accounts (personal or team)
- **AccountUser model**: Join table managing user-account relationships with roles
- **Current account switching**: Users can switch between accounts via `switch_account(account)`
- **Authorization**: Pundit policies scope data by current account

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

### Jumpstart Configuration System
- **Dynamic configuration**: `config/jumpstart.yml` controls enabled features
- **Runtime gem loading**: `Gemfile.jumpstart` loads gems based on configuration
- **Feature toggles**: Payment processors, integrations, background jobs, etc.
- Access via `Jumpstart.config.payment_processors`, `Jumpstart.config.stripe?`, etc.

### Payment Architecture
- **Pay gem (~11.0)**: Unified interface for multiple payment processors
- **Processor-agnostic**: Stripe, Paddle, Braintree, PayPal, Lemon Squeezy support
- **Per-seat billing**: Team accounts with usage-based pricing
- **Subscription management**: In `app/models/account/billing.rb`
- **Email delivery**: Mailgun, Mailpace, Postmark, and Resend use API gems instead of SMTP
- **API client errors**: Raise `UnprocessableContent` for 422 responses (rfc9110)

## Technology Stack

- **Rails 8** with Hotwire (Turbo + Stimulus) and Hotwire Native
- **PostgreSQL** (primary), **SolidQueue** (jobs), **SolidCache** (cache), **SolidCable** (websockets)
- **Import Maps** for JavaScript (no Node.js dependency)
- **TailwindCSS v4** via tailwindcss-rails gem
- **Devise** for authentication with custom extensions
- **Pundit** for authorization
- **Minitest** for testing with parallel execution

## Testing

- **Minitest** with fixtures in `test/fixtures/`
- **System tests** use Capybara with Selenium WebDriver
- **Test parallelization** enabled via `parallelize(workers: :number_of_processors)`
- **WebMock** configured to disable external HTTP requests
- **Test database** reset between runs

## Routes Organization

Routes are modularized in `config/routes/`:
- `accounts.rb` - Account management, switching, invitations
- `billing.rb` - Subscription, payment, receipt routes
- `users.rb` - User profile, settings, authentication
- `api.rb` - API v1 endpoints with JWT authentication

## Key Directories

- `app/controllers/accounts/` - Account-scoped controllers
- `app/models/concerns/` - Shared model modules
- `app/policies/` - Pundit authorization policies
- `lib/jumpstart/` - Core Jumpstart engine and configuration
- `config/routes/` - Modular route definitions
- `app/components/` - View components for reusable UI

## Shuby Chat Assistant

Shuby is an AI-powered chat assistant for child development (0-36 months) integrated using RubyLLM and OpenAI.

### Architecture
- **RubyLLM** (`~> 1.2`) for AI chat functionality with `acts_as_chat` models
- **OpenAI Vector Store** for RAG (Retrieval Augmented Generation)
- **Turbo Streams** for real-time message streaming
- **Custom Tool**: `FileSearchTool` searches OpenAI's hosted Vector Store

### Key Files
```
app/controllers/shuby_chats_controller.rb  # Main controller
app/services/shuby_assistant_service.rb    # Service with system prompt
app/tools/file_search_tool.rb              # Vector Store search tool
app/models/shuby_chat.rb                   # Chat model (acts_as_chat)
app/models/shuby_message.rb                # Message model (acts_as_message)
app/models/shuby_tool_call.rb              # Tool call model (acts_as_tool_call)
config/routes/shuby.rb                     # Routes at /shuby
config/initializers/ruby_llm.rb            # RubyLLM configuration
```

### Configuration
Requires credentials in `bin/rails credentials:edit`:
```yaml
openai:
  api_key: sk-your-api-key
  vector_store_id: vs_your-vector-store-id
```

### Routes
- `GET /shuby` - List conversations
- `GET /shuby/:id` - View conversation
- `POST /shuby` - Create new conversation
- `POST /shuby/:id/message` - Send message (with streaming)
- `DELETE /shuby/:id` - Delete conversation

### Model
Default: `gpt-5-mini` (configurable in `ShubyAssistantService::DEFAULT_MODEL`)

Full documentation: `docs/shuby_setup.md`

## Development Notes

- **Current account** available via `current_account` helper in controllers/views
- **Account switching** via `switch_account(account)` in tests
- **Billing features** conditionally loaded based on `Jumpstart.config.payments_enabled?`
- **Background jobs** configurable between SolidQueue and Sidekiq
- **Multi-database** setup with separate databases for cache, jobs, and cable

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

### Specification Documents
- **Product spec**: `docs/Shuby 1.0 - Specifiche di Prodotto.md` (Italian)
- **Functional analysis**: `docs/Shuby - Analisi Funzionale - v.1.0.pdf` (Italian)
- Always verify implementations against these documents
