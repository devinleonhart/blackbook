#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"

bundle check

# Migrations are a separate command, never run here.
exec bundle exec "$@"
