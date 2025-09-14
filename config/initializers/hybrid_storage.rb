# frozen_string_literal: true

# Configure hybrid storage service for production
Rails.application.configure do
  if Rails.env.production?
    # Set up hybrid storage after Rails initialization
    config.after_initialize do
      # Get the individual services
      local_service = ActiveStorage::Service.configure(:local_production, Rails.application.config.active_storage.service_configurations)
      cloud_service = ActiveStorage::Service.configure(:digitalocean, Rails.application.config.active_storage.service_configurations)

      # Create and register the hybrid service
      hybrid_service = HybridStorageService.new(
        local_service: local_service,
        cloud_service: cloud_service
      )

      # Add it to the service configurations so it can be used
      Rails.application.config.active_storage.service_configurations["hybrid"] = {
        "service" => "Hybrid"
      }

      # Register the hybrid service class
      ActiveStorage::Service.send(:remove_const, :Hybrid) if ActiveStorage::Service.const_defined?(:Hybrid)
      ActiveStorage::Service.const_set(:Hybrid, Class.new(ActiveStorage::Service) do
        def self.build(configurator:, name:, **service_config)
          local_service = ActiveStorage::Service.configure(:local_production, Rails.application.config.active_storage.service_configurations)
          cloud_service = ActiveStorage::Service.configure(:digitalocean, Rails.application.config.active_storage.service_configurations)

          HybridStorageService.new(
            local_service: local_service,
            cloud_service: cloud_service
          )
        end
      end)
    end
  end
end
