# frozen_string_literal: true

require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlackBook
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # using PostgreSQL check constraints requires dumping the schema to SQL
    config.active_record.schema_format = :sql

    # Allow domains for CORS.
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:9000', 'lionheart.design'
        resource '*', headers: :any, methods: [:get, :post, :options], expose: ['access-token', 'expiry', 'token-type', 'uid', 'client']
      end
    end

    # if changing this value, update the documented default value for the
    # page_size parameter to characters#index in the server API section of the
    # readme
    config.pagination_default_page_size = 100
  end
end
