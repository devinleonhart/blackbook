# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlackBook
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # using PostgreSQL check constraints requires dumping the schema to SQL
    config.active_record.schema_format = :sql

    # Allow domains for CORS.
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:9000', 'lionheart.design'
        resource '*', headers: :any, methods: [:get, :post, :options, :put, :delete], expose: ['access-token', 'client', 'expiry', 'token-type', 'uid', ]
      end
    end

  end
end
