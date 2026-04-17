#!/usr/bin/env bash

# exit on error
set -o errexit

while [ $# -gt 0 ] ; do
  case $1 in
    -s | --skip-migrations) SKIP_MIGRATE=true ;;
  esac
  shift
done

bundle install
npm install
bundle exec rails assets:precompile
bundle exec rails assets:clean
if [[ $SKIP_MIGRATE != true ]]; then
  bundle exec rails db:prepare
  # Load schemas for secondary databases (ignore errors if tables already exist)
  bundle exec rails db:schema:load:cache 2>/dev/null || true
  bundle exec rails db:schema:load:queue 2>/dev/null || true
  # Cable table is now created via migration, no need for db:schema:load:cable

  # Seed reference data (idempotent — safe to run on every deploy)
  bundle exec rails db:seed
fi
