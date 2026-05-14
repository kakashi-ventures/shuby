source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "4.0.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.1.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.0"
# Use postgresql as the database for Active Record
gem "pg"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 8.0"
# Rack middleware for blocking & throttling abusive requests [https://github.com/rack/rack-attack]
gem "rack-attack", "~> 6.7"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0.3"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "~> 1.0", ">= 1.0.2"
# Ruby Native — wrap Rails app in native iOS shell [https://rubynative.com]
gem "ruby_native", "~> 0.9"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", "~> 2.14"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", ">= 2.0.0.rc2", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.12"

# Read .docx article sources for archive ingestion (lib/shuby/articles/docx_parser.rb).
# Was only available transitively via selenium-webdriver (test group) — declared
# explicitly so production eager-load of the parser doesn't fail with LoadError.
gem "rubyzip", "~> 3.0"

# AWS S3 for Active Storage in production
gem "aws-sdk-s3", require: false

group :development, :test do
  # Load environment variables from .env
  gem "dotenv-rails"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", ">= 4.1.0"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", ">= 3.39"
  gem "selenium-webdriver", ">= 4.20.1"

  # Accessibility scanning (WCAG 2.1 AA) via axe-core in headless Chrome.
  # axe-core-api drives the audit; axe-core-rspec gives us the matcher object
  # whose passed?/failure_message methods are usable from Minitest too.
  gem "axe-core-api", "~> 4.10"
  gem "axe-core-rspec", "~> 4.10", require: false
end

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 5.1"

# ActionText editor
gem "lexxy", "~> 0.9.0.beta"

# Jumpstart Pro dependencies
require_relative "lib/jumpstart/lib/jumpstart/configuration"
begin
  load "config/jumpstart"
rescue LoadError
end
eval_gemfile "Gemfile.jumpstart"

# We recommend using strong migrations when your app is in production
# gem "strong_migrations"

# Core Rails I18n translations (Italian time/date/number formats)
gem "rails-i18n", "~> 8.0"

# Inline SVG rendering for icons (used by render_svg helper)
gem "inline_svg", "~> 1.6"

# Shuby Chat Assistant - AI integration
gem "ruby_llm", "~> 1.2"
gem "ruby-openai", "~> 7.0"  # For direct Vector Store API calls

# Country/nationality data with I18n support
gem "countries", "~> 6.0"

# PDF generation for pediatrician reports
gem "prawn", "~> 2.5"
gem "prawn-table", "~> 0.2"
