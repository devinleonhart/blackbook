FROM ruby:3.0.1-alpine

#  Docker-specific Environment Variables
ENV APP_PATH /var/app
ENV BUNDLE_VERSION 2.2.21
ENV BUNDLE_PATH /usr/local/bundle/gems
ENV TMP_PATH /tmp/
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_PORT 3000

# Copy Entrypoint scripts and make them executable.
COPY ./entrypoints/prod.sh /usr/local/bin/prod-entrypoint.sh
RUN chmod +x /usr/local/bin/prod-entrypoint.sh

# Install Depencenices
RUN apk -U add --no-cache \
build-base \
git \
postgresql-dev \
postgresql-client \
libxml2-dev \
libxslt-dev \
nodejs \
yarn \
imagemagick \
tzdata \
less \
&& rm -rf /var/cache/apk/* \
&& mkdir -p $APP_PATH

# Install Gems
RUN gem install bundler --version "$BUNDLE_VERSION" \
&& rm -rf $GEM_HOME/cache/*

# Begin.
WORKDIR $APP_PATH
EXPOSE $RAILS_PORT
ENTRYPOINT [ "bundle", "exec" ]
