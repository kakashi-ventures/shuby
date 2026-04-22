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
  # db:prepare applies pending migrations for every logical DB configured
  # (primary, queue, cache, cable). Schema drift from gem upgrades (e.g. new
  # tables in Solid Queue releases) is handled via regular migrations in
  # db/migrate/ with if_not_exists guards — NOT via db:schema:load, which
  # is destructive (force: :cascade drops & recreates tables on every deploy,
  # blowing away queued jobs and cached entries, and is blocked in production
  # by Rails' ProtectedEnvironmentError).
  bundle exec rails db:prepare

  # Seed reference data (idempotent — safe to run on every deploy)
  bundle exec rails db:seed
fi
