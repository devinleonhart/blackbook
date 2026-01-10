# Blackbook

## UI / Tailwind conventions

Reusable Tailwind component classes (minimal set) are documented in `docs/ui-components.md`.

## Setup
```bash
./bin/setup-dev
```

## Start
```bash
docker compose up -d
```

This starts:

- `blackbook`: Rails server
- `css`: Tailwind watcher (`tailwindcss:watch[poll]` for reliable updates on Docker/macOS)

## Database
```bash
./bin/reset-db
./bin/reset-test-db
docker compose exec blackbook bundle exec rails db:migrate
```

## Console
```bash
docker compose exec blackbook bundle exec rails console
```

## Tests
```bash
docker compose exec blackbook bundle exec rspec
```
