FROM ruby:3.0.1-alpine

#  Docker-specific Environment Variables
ENV APP_PATH /var/app
ENV BUNDLE_VERSION 2.2.21
ENV BUNDLE_PATH /usr/local/bundle/gems
ENV TMP_PATH /tmp/
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_PORT 3000

# Install Depencenices
RUN apk -U add --no-cache \
build-base \
tzdata \
postgresql-dev \
postgresql-client \
vips \
&& rm -rf /var/cache/apk/* \
&& mkdir -p $APP_PATH

# Copy Project
COPY . $APP_PATH
WORKDIR $APP_PATH

# Install Gems
RUN gem install bundler --version "$BUNDLE_VERSION" \
&& rm -rf $GEM_HOME/cache/*
RUN bundle install

# Begin
COPY ./entrypoints/prod.sh /usr/local/bin/prod.sh
RUN chmod +x /usr/local/bin/prod.sh
ENTRYPOINT ["prod.sh"]
EXPOSE $RAILS_PORT
CMD ["puma", "-C", "config/puma.rb"]
