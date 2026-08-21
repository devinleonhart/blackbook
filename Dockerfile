FROM ruby:3.4.10-alpine AS base

ENV APP_PATH=/app \
    BUNDLE_VERSION=2.6.2 \
    BUNDLE_PATH=/usr/local/bundle/gems \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_PORT=3000

WORKDIR $APP_PATH

RUN apk add --no-cache \
    curl=8.21.0-r0 \
    postgresql18-client=18.6-r0 \
    tzdata=2026c-r0 \
    vips=8.18.2-r0 \
    yaml=0.2.5-r2

RUN gem install bundler --version "$BUNDLE_VERSION" --no-document

FROM base AS build_base

RUN apk add --no-cache \
    build-base=0.5-r4 \
    git=2.54.0-r0 \
    postgresql18-dev=18.6-r0 \
    vips-dev=8.18.2-r0 \
    yaml-dev=0.2.5-r2

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

RUN addgroup -g 1000 -S rails && \
    adduser -u 1000 -S rails -G rails

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=rails:rails $APP_PATH $APP_PATH

COPY --chmod=755 ./entrypoints/prod.sh /usr/local/bin/prod.sh

USER rails

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:$RAILS_PORT/up || exit 1

EXPOSE $RAILS_PORT

ENTRYPOINT ["prod.sh"]
CMD ["puma", "-C", "config/puma.rb"]
