#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"

if ! bundle check; then
  echo "ERROR: Missing gems. Rebuild the dev image to install them:"
  echo "  docker compose build blackbook"
  exit 1
fi

# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server.pid

echo "Building Tailwind CSS…"
bundle exec rails tailwindcss:build
rm -rf $APP_PATH/public/assets || true

# run passed commands
bundle exec ${@}
