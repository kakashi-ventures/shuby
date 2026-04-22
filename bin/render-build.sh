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
  # Load schemas for secondary "logical" DBs (cache, queue). These share the
  # same physical DB as primary but have their own schema files
  # (db/cache_schema.rb, db/queue_schema.rb) with `force: :cascade`, so
  # re-running is idempotent (drops + recreates the tables). Re-running is
  # REQUIRED when new tables are added upstream (e.g. Solid Queue 1.0 added
  # solid_queue_recurring_tasks) — previously these errors were silenced
  # with `2>/dev/null || true`, which masked schema drift and left the
  # worker unable to start. Let failures surface so the deploy fails fast.
  bundle exec rails db:schema:load:cache
  bundle exec rails db:schema:load:queue
  # Cable table is now created via migration, no need for db:schema:load:cable

  # Seed reference data (idempotent — safe to run on every deploy)
  bundle exec rails db:seed
fi
