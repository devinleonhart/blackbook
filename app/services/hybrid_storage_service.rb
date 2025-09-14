# frozen_string_literal: true

# Hybrid storage service that saves to both local and cloud,
# and tries local first when reading
class HybridStorageService < ActiveStorage::Service
  attr_reader :local_service, :cloud_service

  def initialize(local_service:, cloud_service:)
    @local_service = local_service
    @cloud_service = cloud_service
  end

  # Upload to both local and cloud
  def upload(key, io, checksum: nil, **options)
    # Reset IO position for multiple reads
    io.rewind if io.respond_to?(:rewind)

    # Read content once to avoid multiple IO operations
    content = io.read
    io_local = StringIO.new(content)
    io_cloud = StringIO.new(content)

    # Upload to both services
    results = {}

    begin
      results[:local] = local_service.upload(key, io_local, checksum: checksum, **options)
      Rails.logger.info("Successfully uploaded #{key} to local storage")
    rescue => e
      Rails.logger.error("Failed to upload #{key} to local storage: #{e.message}")
      results[:local] = { error: e.message }
    end

    begin
      results[:cloud] = cloud_service.upload(key, io_cloud, checksum: checksum, **options)
      Rails.logger.info("Successfully uploaded #{key} to cloud storage")
    rescue => e
      Rails.logger.error("Failed to upload #{key} to cloud storage: #{e.message}")
      results[:cloud] = { error: e.message }
    end

    # Return the first successful result (prefer local)
    return results[:local] if results[:local] && !results[:local].is_a?(Hash)
    return results[:cloud] if results[:cloud] && !results[:cloud].is_a?(Hash)

    # If both failed, raise an error
    raise "Failed to upload to both storages: Local: #{results[:local][:error]}, Cloud: #{results[:cloud][:error]}"
  end

  # Try local first, fallback to cloud
  def download(key, &block)
    begin
      return local_service.download(key, &block)
    rescue => e
      Rails.logger.warn("Failed to download #{key} from local storage, trying cloud: #{e.message}")
      return cloud_service.download(key, &block)
    end
  end

  # Try local first, fallback to cloud
  def download_chunk(key, range)
    begin
      return local_service.download_chunk(key, range)
    rescue => e
      Rails.logger.warn("Failed to download chunk #{key} from local storage, trying cloud: #{e.message}")
      return cloud_service.download_chunk(key, range)
    end
  end

  # Delete from both services
  def delete(key)
    local_result = nil
    cloud_result = nil

    begin
      local_result = local_service.delete(key)
      Rails.logger.info("Deleted #{key} from local storage")
    rescue => e
      Rails.logger.error("Failed to delete #{key} from local storage: #{e.message}")
    end

    begin
      cloud_result = cloud_service.delete(key)
      Rails.logger.info("Deleted #{key} from cloud storage")
    rescue => e
      Rails.logger.error("Failed to delete #{key} from cloud storage: #{e.message}")
    end

    local_result || cloud_result
  end

  # Delete files from both services
  def delete_prefixed(prefix)
    local_service.delete_prefixed(prefix) rescue nil
    cloud_service.delete_prefixed(prefix) rescue nil
  end

  # Check if file exists (try local first, then cloud)
  def exist?(key)
    begin
      return true if local_service.exist?(key)
    rescue => e
      Rails.logger.debug("Local existence check failed for #{key}: #{e.message}")
    end

    begin
      return cloud_service.exist?(key)
    rescue => e
      Rails.logger.debug("Cloud existence check failed for #{key}: #{e.message}")
      return false
    end
  end

  # Generate URL (prefer local for better performance, fallback to cloud)
  def url(key, expires_in:, filename:, disposition:, content_type:)
    begin
      if local_service.exist?(key)
        return local_service.url(key, expires_in: expires_in, filename: filename, disposition: disposition, content_type: content_type)
      end
    rescue => e
      Rails.logger.debug("Local URL generation failed for #{key}: #{e.message}")
    end

    # Fallback to cloud
    cloud_service.url(key, expires_in: expires_in, filename: filename, disposition: disposition, content_type: content_type)
  end

  # Generate public URL if available
  def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
    # For uploads, prefer cloud for reliability, but could be either
    cloud_service.url_for_direct_upload(key, expires_in: expires_in, content_type: content_type, content_length: content_length, checksum: checksum)
  end

  # Headers for direct upload
  def headers_for_direct_upload(key, content_type:, checksum:, **)
    cloud_service.headers_for_direct_upload(key, content_type: content_type, checksum: checksum)
  end

  # Path for file (local service only)
  def path_for(key)
    local_service.path_for(key) if local_service.respond_to?(:path_for)
  end

  # Get service name
  def name
    "hybrid"
  end
end
