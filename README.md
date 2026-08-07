# Blackbook

A wiki for tabletop-RPG **universes**. Create a universe, populate it with
**characters** and **images**, tag images with the characters in them, tag
characters with freeform labels, favorite images, and browse them as a
**slideshow**. Share a universe with **collaborators**; admins get user
management and an image-deduplication tool.

## Tech stack

- **Ruby 3.4** / **Rails 8.1** / **PostgreSQL 18**
- **Devise** for authentication
- **Hotwire** (Turbo + Stimulus) delivered through **importmap** — no JS build step
- **Tailwind CSS v4** via `tailwindcss-rails` (standalone binary)
- **Active Storage** (libvips) for image uploads
- **RSpec** + shoulda-matchers + FactoryBot; **SimpleCov** enforces 100% line coverage
- Docker Compose for the local dev environment

## Prerequisites

- **Docker** + **Docker Compose** (the whole dev stack runs in containers)
- That's it for day-to-day work. Running Rails commands directly on your host
  additionally needs Ruby 3.4 (e.g. via [asdf](https://asdf-vm.com/)) and
  `libvips` (`brew install vips`).

## Setup

```bash
bin/setup-dev
```

This builds the images and creates + seeds the development database.

## Running the app

```bash
docker compose up -d
```

Starts three services:

- **blackbook** — the Rails server, available at **http://localhost:3001**
- **css** — Tailwind watcher that rebuilds styles on change
- **postgres_db** — PostgreSQL (exposed on host port `5434`)

The seed data creates sample universes and these logins (all password
`password123`):

| Email | Role |
| --- | --- |
| `admin@blackbook.dev` | admin |
| `owner@blackbook.dev` | universe owner |
| `collaborator@blackbook.dev` | collaborator |

## Common commands

Run these inside the container (`docker compose exec blackbook …`):

```bash
docker compose exec blackbook bundle exec rails console   # Rails console
docker compose exec blackbook bundle exec rspec           # run the test suite
docker compose exec blackbook bundle exec rails db:migrate # apply migrations
```

Database helpers (from the host):

```bash
bin/reset-db        # drop, create, migrate, and seed the development database
bin/reset-test-db   # reset the test database
```

## Tests & checks

```bash
bin/ci
```

`bin/ci` runs the full quality gate — RuboCop, Brakeman, bundler-audit, a
Tailwind build, and the RSpec suite — and is exactly what CI runs on every push.
The suite is order-randomized; reproduce a failing order with
`bundle exec rspec --seed N`. **Coverage must stay at 100% line coverage** or the
build fails.

## How the app fits together

- **Domain:** `User`s own `Universe`s and can be added as collaborators on
  others'. A universe has `Character`s and `Image`s. `ImageTag` links an image to
  the characters in it; `CharacterTag` is a freeform label on a character;
  `ImageFavorite` marks a user's favorite images.
- **Authorization:** a universe is visible to its owner and collaborators
  (`Universe#visible_to_user?` / `Universe.accessible_to`). Controllers load and
  authorize records in `before_action` setters; managing collaborators is
  owner-only; user management and the dedupe tool are admin-only.
- **Front end:** server-rendered ERB enhanced with Turbo and small Stimulus
  controllers (`app/javascript/controllers`). JavaScript is pinned in
  `config/importmap.rb` — there is no bundler.
- **Styling:** Tailwind utility classes plus a small set of reusable `bb-*`
  component classes defined in `app/assets/tailwind/application.css`.
- **Security:** a strict Content-Security-Policy (same-origin only, nonce-based)
  is enforced in `config/initializers/content_security_policy.rb`.
