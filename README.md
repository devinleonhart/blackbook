# Blackbook

## Setup
```bash
./bin/setup-dev
```

## Start
```bash
docker compose up -d
```

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
