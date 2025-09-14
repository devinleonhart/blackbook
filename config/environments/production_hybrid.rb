# frozen_string_literal: true

# This is an example production configuration for hybrid storage
# Copy this to production.rb when ready to enable hybrid mode

require_relative "production"

Rails.application.configure do
  # Use hybrid storage instead of just digitalocean
  config.active_storage.service = :hybrid

  # Enable more detailed logging for storage operations during migration
  config.log_level = :info

  # Add custom logger for image migration tracking
  config.after_initialize do
    # Create a separate log file for image operations
    image_logger = ActiveSupport::Logger.new(Rails.root.join("log", "images.log"))
    image_logger.level = Logger::INFO

    # Make it available globally
    Rails.application.config.image_logger = image_logger
  end
end
