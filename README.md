# Blackbook

Keeps the characters and images of fictional universes, shared with collaborators.

## Features

- **Universes**: a user owns universes and may add collaborators to them.
- **Characters**: belong to a universe and carry traits.
- **Images**: uploaded to a universe and tagged with the characters in them.
- **Favorites, random image and slideshow**: for looking through a universe's images.
- **Administration**: admins manage users and remove duplicate images.
- **Import**: `POST /api/discord_imports/images` takes images from a Discord bot that has the import token.
- **MCP**: `/mcp`, for hosts and tokens that are allowed.

## Development

Needs Docker; the application, the Tailwind watcher and PostgreSQL run in containers.

```bash
bin/setup-dev                                            # builds the images, creates and seeds the database
docker compose up -d                                     # http://localhost:3001
docker compose run --rm -e RAILS_ENV=test web bin/ci     # everything CI checks; ends in OK
bin/reset-db                                             # drops, creates, migrates and seeds development
```

The seeds create `admin@blackbook.dev`, `owner@blackbook.dev` and `collaborator@blackbook.dev`, each with the password `password123`.

## Environment

| Variable | Purpose |
|---|---|
| `DATABASE_URL` | Production database |
| `DEVELOPMENT_DATABASE_URL`, `TEST_DATABASE_URL` | Set by compose; not `DATABASE_URL`, which would apply to both |
| `RAILS_MASTER_KEY` | Production secret |
| `DISCORD_IMPORT_TOKEN` | The token of the import address; without it, imports are refused |
| `SMTP_USERNAME`, `SMTP_PASSWORD` | Mail, for password resets |
| `MCP_HOST` | The only host that `/mcp` answers; unset, `/mcp` does not exist |
| `APP_HOST` | The host production answers to (default `blackbook.devleo.me`) |

## MCP

`POST /mcp` offers a user's universes, characters, traits, images and favorites as tools. Images are given by address, never as data.

Each machine has its own token, which belongs to a user, carries `read`, `write` or `delete`, and expires:

```bash
bin/rails mcp:tokens:issue USER=<email> MACHINE=<name> SCOPES=read,write DAYS=90   # prints the token once
bin/rails mcp:tokens:list
bin/rails mcp:tokens:revoke ID=<id>
```

The endpoint, limits and tokens come from the [`tailnet_mcp`](https://github.com/devinleonhart/tailnet-mcp) gem. The tools are in `app/mcp`, and may only use records that `BlackbookMcp::Access` gives.

## Deployment

A merge to `master` runs CI, which publishes `devleo/blackbook:latest` to Docker Hub when the checks pass. On the server:

```bash
docker compose pull blackbook
docker compose run --rm --no-deps blackbook bin/rails db:migrate   # only with a new migration
docker compose up -d blackbook
```

Migrations never run at boot.

## Architecture

- **Access**: a universe is visible to its owner and collaborators (`Universe.accessible_to`). Controllers load and authorize records in `before_action` setters.
- **Pages**: ERB with Turbo and Stimulus controllers, pinned in `config/importmap.rb`. There is no JavaScript build.
- **Styles**: Tailwind, with a few `bb-*` component classes in `app/assets/tailwind/application.css`.
- **Images**: Active Storage with libvips.
- **Security**: a Content-Security-Policy of the same origin with nonces, in `config/initializers/content_security_policy.rb`.
