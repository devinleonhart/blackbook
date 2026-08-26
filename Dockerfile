FROM ruby:3.4.10-slim-bookworm AS base

ENV APP_PATH=/app \
    BUNDLE_VERSION=2.6.2 \
    BUNDLE_PATH=/usr/local/bundle/gems \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_PORT=3000

WORKDIR $APP_PATH

# Runtime libraries. Debian's libpq (postgresql-client) speaks to any modern
# server, so the client version no longer has to track the prod Postgres major.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libvips42 \
    postgresql-client \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN gem install bundler --version "$BUNDLE_VERSION" --no-document

FROM base AS build_base

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    libvips-dev \
    libyaml-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

FROM build_base AS dev

ENV RAILS_ENV=development \
    NODE_ENV=development

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:$RAILS_PORT/up || exit 1

COPY --chmod=755 ./entrypoints/development.sh /usr/local/bin/development.sh

EXPOSE $RAILS_PORT

ENTRYPOINT ["development.sh"]
CMD ["puma", "-C", "config/puma.rb"]

FROM build_base AS builder

ENV BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_FROZEN=1 \
    RAILS_ENV=production \
    NODE_ENV=production

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
    bundle clean --force && \
    rm -rf /usr/local/bundle/cache/*.gem

COPY . .

RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

FROM base AS runtime

ENV BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_FROZEN=1 \
    RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

RUN groupadd --gid 1000 rails && \
    useradd --uid 1000 --gid rails --create-home --shell /bin/bash rails

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=rails:rails $APP_PATH $APP_PATH

COPY --chmod=755 ./entrypoints/prod.sh /usr/local/bin/prod.sh

USER rails

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:$RAILS_PORT/up || exit 1

EXPOSE $RAILS_PORT

ENTRYPOINT ["prod.sh"]
CMD ["puma", "-C", "config/puma.rb"]
