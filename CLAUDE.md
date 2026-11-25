# Blackbook

Read README.md for commands, addresses and variables. Rails 8.1 on Ruby 4.0, Hotwire, PostgreSQL, Active Storage
with libvips, Devise.

- All Ruby runs in containers. `docker compose run --rm -e RAILS_ENV=test web bin/ci` is everything CI checks.
- Production reads `DATABASE_URL`. Development and test read their own variables, so specs cannot erase development
  data.
- Production answers only to `APP_HOST` and to `blackbook`, the name Memo uses on the server's internal network.
  `/up` and `/mcp` are exempt. Another way of reaching the application needs its host in `config.hosts`.
- A universe is visible to its owner and collaborators only. Controllers and MCP tools take records through that
  check (`Universe.accessible_to`, `BlackbookMcp::Access`), never by id alone.
- MCP gives images by address, never as data. The endpoint and tokens are the `tailnet_mcp` gem's.
- `web` and `css` share one image in compose; building either renews both.
- Migrations never run at boot.
