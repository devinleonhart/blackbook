# frozen_string_literal: true

# Concern for enhanced image storage capabilities during migration
module ImageStorageConcern
  extend ActiveSupport::Concern

  included do
    # Add callback to log image operations
    after_create :log_image_creation
    after_destroy :log_image_deletion

    # Track descriptive filenames
    attr_accessor :local_filename
  end

  def image_available_locally?
    return false unless image_file.attached?

    # Check both original Active Storage path and descriptive filename path
    if Rails.env.production? && Rails.application.config.active_storage.service == :hybrid
      begin
        blob = image_file.blob

        # Check original Active Storage path
        original_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
        return true if File.exist?(original_path) && File.size(original_path) == blob.byte_size

        # Check descriptive filename path
        descriptive_filename = get_or_generate_local_filename
        if descriptive_filename
          descriptive_path = DescriptiveFilenameService.send(:local_file_path_for_filename, descriptive_filename)
          return true if File.exist?(descriptive_path) && File.size(descriptive_path) == blob.byte_size
        end

        false
      rescue => e
        Rails.logger.debug("Error checking local availability for image #{id}: #{e.message}")
        false
      end
    else
      # In development or non-hybrid mode, assume it's available
      true
    end
  end

  def image_available_in_cloud?
    return false unless image_file.attached?

    begin
      # Try to access the cloud service directly
      if Rails.env.production?
        cloud_service = ActiveStorage::Service.configure(:digitalocean, Rails.application.config.active_storage.service_configurations)
        cloud_service.exist?(image_file.blob.key)
      else
        # In development, assume cloud is available if we have credentials
        Rails.application.credentials.dig(:digitalocean, :endpoint).present?
      end
    rescue => e
      Rails.logger.debug("Error checking cloud availability for image #{id}: #{e.message}")
      false
    end
  end

  def storage_status
    {
      local: image_available_locally?,
      cloud: image_available_in_cloud?,
      blob_key: image_file.attached? ? image_file.blob.key : nil,
      file_size: image_file.attached? ? image_file.blob.byte_size : nil
    }
  end

  # Get or generate the descriptive local filename
  def get_or_generate_local_filename
    return @local_filename if @local_filename.present?

    @local_filename = DescriptiveFilenameService.generate_for_image(self)
  end

  # Update filename when characters change
  def update_local_filename!
    old_filename = @local_filename
    @local_filename = DescriptiveFilenameService.update_filename_for_image(self)

    if old_filename != @local_filename
      log_image_event("Updated local filename", { old_filename: old_filename, new_filename: @local_filename })
    end

    @local_filename
  end

  # Get the local file path for descriptive filename
  def local_file_path
    filename = get_or_generate_local_filename
    return nil unless filename

    DescriptiveFilenameService.send(:local_file_path_for_filename, filename)
  end

  # Download and save image with descriptive filename
  def download_to_local_with_descriptive_name!
    return false unless image_file.attached?

    begin
      descriptive_filename = get_or_generate_local_filename
      return false unless descriptive_filename

      local_path = DescriptiveFilenameService.send(:local_file_path_for_filename, descriptive_filename)

      # Skip if already exists with correct size
      if File.exist?(local_path) && File.size(local_path) == image_file.blob.byte_size
        log_image_event("Local file already exists", { filename: descriptive_filename })
        return true
      end

      # Create directory structure
      FileUtils.mkdir_p(File.dirname(local_path))

      # Download and save the file
      File.open(local_path, 'wb') do |file|
        image_file.download { |chunk| file.write(chunk) }
      end

      # Verify the file was saved correctly
      if File.exist?(local_path) && File.size(local_path) == image_file.blob.byte_size
        log_image_event("Downloaded to local with descriptive name", {
          filename: descriptive_filename,
          size: File.size(local_path)
        })
        true
      else
        raise "File size mismatch after download"
      end

    rescue => e
      Rails.logger.error("Failed to download image #{id} with descriptive name: #{e.message}")
      false
    end
  end

  # Force re-sync to both storages (useful for fixing failed uploads)
  def resync_to_both_storages!
    return false unless image_file.attached?

    begin
      # Download the file from whichever storage has it
      temp_file = Tempfile.new(['resync', File.extname(image_file.blob.filename.to_s)])

      image_file.download do |chunk|
        temp_file.write(chunk)
      end

      temp_file.rewind

      # Re-attach with the same key to trigger upload to both storages
      blob = image_file.blob
      new_attachment = image_file.attach(
        io: temp_file,
        filename: blob.filename,
        content_type: blob.content_type
      )

      temp_file.close
      temp_file.unlink

      log_image_event("Resynced image to both storages")
      true
    rescue => e
      Rails.logger.error("Failed to resync image #{id}: #{e.message}")
      false
    end
  end

  private

  def log_image_creation
    log_image_event("Created", storage_status)
  end

  def log_image_deletion
    log_image_event("Deleted")
  end

  def log_image_event(event, extra_data = {})
    return unless Rails.application.config.respond_to?(:image_logger)

    log_data = {
      timestamp: Time.current.iso8601,
      event: event,
      image_id: id,
      universe_id: universe_id,
      filename: image_file.attached? ? image_file.blob.filename.to_s : nil
    }.merge(extra_data)

    Rails.application.config.image_logger&.info(log_data.to_json)
  rescue => e
    Rails.logger.debug("Failed to log image event: #{e.message}")
  end
end
