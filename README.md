# 🎉 Jumpstart Pro Rails

Welcome! To get started, clone the repository and push it to a new repository.

## Requirements

You'll need the following installed to run the template successfully:

* Ruby 3.2+
* PostgreSQL 12+ (can be switched to SQLite or MySQL)
* Libvips or Imagemagick

Optionally, the [Stripe CLI](https://docs.stripe.com/stripe-cli) to sync webhooks in development.

## Create Your Repository

Create a [new Git](https://github.com/new) repository for your project. Then you can clone Jumpstart Pro and push it to your new repository.

```bash
git clone https://github.com/jumpstart-pro/jumpstart-pro-rails.git myapp
cd myapp
git remote rename origin jumpstart-pro
git remote add origin https://github.com/your-account/your-repo.git # Replace with your new Git repository url
git push -u origin main
```

## Initial Setup

First, edit `config/database.yml` and change the database credentials for your server.

Run `bin/setup` to install Ruby and JavaScript dependencies and setup your database.

```bash
bin/setup
```

## Running Jumpstart Pro Rails

To run your application, you'll use the `bin/dev` command:

```bash
bin/dev
```

This starts up Overmind running the processes defined in `Procfile.dev`. We've configured this to run the Rails server, CSS bundling, and JS bundling out of the box. You can add background workers like Sidekiq, the Stripe CLI, etc to have them run at the same time.

#### Running on Windows

See the [Installation docs](https://jumpstartrails.com/docs/installation#windows)

#### Running with Docker or Docker Compose

See the [Installation docs](https://jumpstartrails.com/docs/installation#docker)

## Merging Updates

To merge changes from Jumpstart Pro, you will merge from the `jumpstart-pro` remote.

```bash
git fetch jumpstart-pro
git merge jumpstart-pro/main
```

## Local Development Quick Start

If `bin/dev` (Overmind) doesn't work, start services individually:

```bash
bin/rails db:migrate                  # Always run first — pending migrations cause 500s
bin/rails db:seed                     # Populate questionnaires, growth phases, archive content
bin/rails server -p 3000              # Web server (use -p 3001 if 3000 is occupied)
bin/rails tailwindcss:watch           # CSS hot reload (separate terminal)
bin/jobs                              # SolidQueue background worker (separate terminal)
```

### Dev Test User

The dev database starts empty. Create a test admin user with:

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

## Shuby Chat Assistant

This application includes **Shuby**, an AI-powered chat assistant for child development (0-36 months).

### Setup Shuby

1. Add your OpenAI credentials:
```bash
bin/rails credentials:edit
```

Add:
```yaml
openai:
  api_key: sk-your-api-key
  vector_store_id: vs_your-vector-store-id
```

2. Access Shuby at `/shuby` (requires login)

For full documentation, see `docs/shuby_setup.md`.

## Contributing

If you have an improvement you'd like to share, create a fork of the repository and send us a pull request.
