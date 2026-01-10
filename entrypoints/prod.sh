#!/bin/sh

set -e

echo "Environment: $RAILS_ENV"

bundle check

# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server.pid

# run passed commands
bundle exec ${@}
