require_relative "boot"

require "logger"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Blackbook
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Serve Active Storage images (blobs and variants) through the app in proxy
    # mode rather than redirecting to short-lived signed URLs. Proxy URLs are
    # stable and non-expiring, and the bytes stream back with long-lived public
    # caching — so the browser caches them instead of re-fetching on every paint.
    #
    # The default :rails_storage_redirect mode issues a 302 to a signed disk URL
    # that expires in ~5 minutes and whose bytes are sent `must-revalidate`. On
    # mobile Safari, rapid Turbo navigation cancels those uncached byte requests
    # (broken-image icons) and stale cached redirects point at expired URLs, so
    # images stay broken until a hard refresh. Proxy mode removes that whole
    # redirect/expiry dance.
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
