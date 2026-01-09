FROM ruby:3.3.7-alpine AS builder

ENV APP_PATH=/app \
    BUNDLE_VERSION=2.6.2 \
    BUNDLE_PATH=/usr/local/bundle/gems \
    BUNDLE_WITHOUT=development:test \
    RAILS_ENV=production \
    NODE_ENV=production

RUN apk add --no-cache \
    build-base=0.5-r3 \
    git=2.47.3-r0 \
    postgresql17-dev=17.7-r0 \
    tzdata=2025c-r0 \
    vips-dev=8.15.3-r5 \
    yaml-dev=0.2.5-r2

WORKDIR $APP_PATH

COPY Gemfile Gemfile.lock ./
RUN gem install bundler --version "$BUNDLE_VERSION" --no-document && \
    bundle install --jobs 4 --retry 3 && \
    bundle clean --force && \
    rm -rf /usr/local/bundle/cache/*.gem

COPY . .

RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

FROM ruby:3.3.7-alpine

ENV APP_PATH=/app \
    BUNDLE_VERSION=2.6.2 \
    BUNDLE_PATH=/usr/local/bundle/gems \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_PORT=3000

RUN apk add --no-cache \
    curl=8.14.1-r2 \
    postgresql17-client=17.7-r0 \
    tzdata=2025c-r0 \
    vips=8.15.3-r5 \
    yaml=0.2.5-r2 && \
    addgroup -g 1000 -S rails && \
    adduser -u 1000 -S rails -G rails

WORKDIR $APP_PATH

COPY --from=builder /usr/local/bundle /usr/local/bundle

COPY --from=builder --chown=rails:rails $APP_PATH $APP_PATH

COPY --chmod=755 ./entrypoints/prod.sh /usr/local/bin/prod.sh

USER rails

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:$RAILS_PORT/up || exit 1

EXPOSE $RAILS_PORT

ENTRYPOINT ["prod.sh"]
CMD ["puma", "-C", "config/puma.rb"]
