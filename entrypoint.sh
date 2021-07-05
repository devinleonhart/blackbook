#!/bin/bash
set -e
rm -f /blackbook-rails/tmp/pids/server.pid
exec "$@"
