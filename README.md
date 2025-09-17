# Blackbook
Track your fictional universes with ease.

## Local Development

### Quick Start
```bash
# Complete development environment setup
./bin/setup-dev

# Or manually:
docker compose up -d
bin/rails db:create db:migrate db:seed
```

### Available Scripts

#### Database Management
```bash
# Reset and seed development database
./bin/reset-db
# or
bin/rails db:dev_reset

# Reset and seed test database
./bin/reset-test-db
# or
bin/rails db:test_reset

# Seed both development and test databases
bin/rails db:seed_all

# Show database statistics
bin/rails db:stats
```

#### Development Commands
```bash
# Start the application
docker compose up

# Run tests
docker compose exec blackbook bundle exec rspec

# Access Rails console
docker compose exec blackbook bundle exec rails console

# Run migrations
docker compose exec blackbook bundle exec rails db:migrate
```

## Tests

```bash
# Run all tests
docker compose exec blackbook bundle exec rspec

# Run specific test file
docker compose exec blackbook bundle exec rspec spec/models/character_spec.rb
```

## Tooling
Here are some notes to help when working with this project.

### asdf
[asdf](https://asdf-vm.com/) is what I use locally for tool versioning locally.

```bash
asdf install ruby latest
asdf local ruby latest
```

### docker

[ruby:3.2.1-alpine] (https://hub.docker.com/_/ruby/)
[postgres:12.5-alpine] (https://hub.docker.com/_/postgres)
