FROM ruby:3.2.1-alpine

ENV APP_PATH=/var/app \
    BUNDLE_VERSION=2.2.21 \
    BUNDLE_PATH=/usr/local/bundle/gems \
    TMP_PATH=/tmp/ \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_PORT=3000 \
    RAILS_ENV=production

# Install system deps
RUN apk -U add --no-cache \
    build-base \
    tzdata \
    postgresql-dev \
    postgresql-client \
    vips \
 && rm -rf /var/cache/apk/* \
 && mkdir -p $APP_PATH

# Install gems
WORKDIR $APP_PATH
COPY Gemfile Gemfile.lock ./
RUN gem install bundler --version "$BUNDLE_VERSION"
RUN bundle install

# Copy the rest of the app
COPY . .

# Precompile assets (includes tailwind build)
RUN bundle exec rails assets:precompile

# Entrypoint
COPY ./entrypoints/prod.sh /usr/local/bin/prod.sh
RUN chmod +x /usr/local/bin/prod.sh
ENTRYPOINT ["prod.sh"]

EXPOSE $RAILS_PORT
CMD ["puma", "-C", "config/puma.rb"]
