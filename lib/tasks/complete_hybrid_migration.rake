# frozen_string_literal: true

namespace :images do
  desc "Complete migration to hybrid storage with local copies of all images"
  task complete_hybrid_migration: :environment do
    puts "Complete Hybrid Storage Migration"
    puts "=" * 60
    puts "This task will:"
    puts "1. Download all cloud images to local storage"
    puts "2. Convert all blobs to use hybrid service"
    puts "3. Verify all images are available locally"
    puts "4. Prepare system for eventual cloud removal"
    puts "=" * 60

    # Track overall progress
    total_blobs = ActiveStorage::Blob.count
    puts "Total blobs to process: #{total_blobs}"

    if total_blobs == 0
      puts "No blobs found. Nothing to migrate."
      return
    end

    # Show current state
    puts "\nCurrent service distribution:"
    service_counts = ActiveStorage::Blob.group(:service_name).count
    service_counts.each do |service, count|
      puts "  #{service}: #{count} blobs"
    end

    # Phase 1: Download all images to local storage
    puts "\n" + "=" * 60
    puts "PHASE 1: Downloading images to local storage"
    puts "=" * 60

    downloaded_count = 0
    already_local_count = 0
    download_failed_count = 0
    failed_downloads = []

    # Create storage directory structure
    storage_root = Rails.root.join("storage")
    FileUtils.mkdir_p(storage_root)

    ActiveStorage::Blob.find_each(batch_size: 10) do |blob|
      begin
        # Determine local path using Active Storage's structure
        local_path = storage_root.join(blob.key[0..1], blob.key[2..3], blob.key)

        # Check if file already exists locally with correct size
        if File.exist?(local_path) && File.size(local_path) == blob.byte_size
          puts "  ✓ Already local: #{blob.filename} (#{blob.key[0..7]}...)"
          already_local_count += 1
          next
        end

        puts "  → Downloading: #{blob.filename} (#{human_size(blob.byte_size)}) (#{blob.key[0..7]}...)"

        # Create directory structure
        FileUtils.mkdir_p(File.dirname(local_path))

        # Download from current service
        success = download_blob_to_local(blob, local_path)

        if success
          puts "    ✓ Downloaded successfully"
          downloaded_count += 1
        else
          puts "    ✗ Download failed"
          download_failed_count += 1
          failed_downloads << {
            id: blob.id,
            filename: blob.filename.to_s,
            key: blob.key,
            service: blob.service_name,
            size: blob.byte_size
          }
        end

        # Small delay to avoid overwhelming the system
        sleep(0.1)

      rescue => e
        puts "  ✗ Error downloading blob #{blob.id} (#{blob.filename}): #{e.message}"
        download_failed_count += 1
        failed_downloads << {
          id: blob.id,
          filename: blob.filename.to_s,
          key: blob.key,
          service: blob.service_name,
          error: e.message
        }
      end

      # Progress update
      processed = downloaded_count + already_local_count + download_failed_count
      if processed % 25 == 0
        puts "    Progress: #{processed}/#{total_blobs} processed"
      end
    end

    puts "\nPhase 1 Summary:"
    puts "  Already local: #{already_local_count}"
    puts "  Downloaded: #{downloaded_count}"
    puts "  Failed: #{download_failed_count}"

    # Phase 2: Convert all blobs to hybrid service
    puts "\n" + "=" * 60
    puts "PHASE 2: Converting blobs to hybrid service"
    puts "=" * 60

    conversion_success_count = 0
    conversion_failed_count = 0
    conversion_skipped_count = 0
    failed_conversions = []

    ActiveStorage::Blob.where.not(service_name: 'hybrid').find_each(batch_size: 50) do |blob|
      begin
        # Only convert if we have a local copy
        local_path = storage_root.join(blob.key[0..1], blob.key[2..3], blob.key)

        if File.exist?(local_path) && File.size(local_path) == blob.byte_size
          old_service = blob.service_name
          blob.update!(service_name: 'hybrid')
          puts "  ✓ Converted blob #{blob.id} (#{blob.filename}) from '#{old_service}' to 'hybrid'"
          conversion_success_count += 1
        else
          puts "  ⚠ Skipping blob #{blob.id} (#{blob.filename}) - no valid local file"
          conversion_skipped_count += 1
          failed_conversions << {
            id: blob.id,
            filename: blob.filename.to_s,
            key: blob.key,
            reason: "No local file or size mismatch"
          }
        end

      rescue => e
        puts "  ✗ Failed to convert blob #{blob.id}: #{e.message}"
        conversion_failed_count += 1
        failed_conversions << {
          id: blob.id,
          filename: blob.filename&.to_s || 'unknown',
          error: e.message
        }
      end
    end

    puts "\nPhase 2 Summary:"
    puts "  Converted to hybrid: #{conversion_success_count}"
    puts "  Skipped (no local file): #{conversion_skipped_count}"
    puts "  Failed: #{conversion_failed_count}"

    # Phase 3: Verification
    puts "\n" + "=" * 60
    puts "PHASE 3: Verification"
    puts "=" * 60

    hybrid_blobs = ActiveStorage::Blob.where(service_name: 'hybrid')
    local_verified = 0
    local_failed = 0

    puts "Verifying #{hybrid_blobs.count} hybrid blobs have local storage..."

    hybrid_blobs.find_each do |blob|
      local_path = storage_root.join(blob.key[0..1], blob.key[2..3], blob.key)

      if File.exist?(local_path) && File.size(local_path) == blob.byte_size
        local_verified += 1
      else
        local_failed += 1
        puts "  ⚠ Verification failed for #{blob.filename} (#{blob.key[0..7]}...)"
      end
    end

    # Final Summary
    puts "\n" + "=" * 60
    puts "MIGRATION COMPLETE"
    puts "=" * 60

    puts "\nFinal service distribution:"
    ActiveStorage::Blob.group(:service_name).count.each do |service, count|
      puts "  #{service}: #{count} blobs"
    end

    puts "\nVerification results:"
    puts "  Hybrid blobs with local storage: #{local_verified}"
    puts "  Hybrid blobs missing local storage: #{local_failed}"

    total_success = local_verified
    success_rate = total_blobs > 0 ? ((total_success.to_f / total_blobs) * 100).round(2) : 0

    puts "\nOverall Success Rate: #{success_rate}% (#{total_success}/#{total_blobs})"

    # Calculate storage usage
    total_local_size = 0
    ActiveStorage::Blob.where(service_name: 'hybrid').find_each do |blob|
      local_path = storage_root.join(blob.key[0..1], blob.key[2..3], blob.key)
      total_local_size += File.size(local_path) if File.exist?(local_path)
    end

    puts "Total local storage used: #{human_size(total_local_size)}"

    # Report issues
    if failed_downloads.any?
      puts "\n" + "⚠" * 3 + " DOWNLOAD FAILURES " + "⚠" * 3
      failed_downloads.each do |failed|
        puts "  Blob #{failed[:id]} (#{failed[:filename]})"
        puts "    Key: #{failed[:key]}"
        puts "    Service: #{failed[:service]}"
        puts "    Size: #{human_size(failed[:size])}" if failed[:size]
        puts "    Error: #{failed[:error]}" if failed[:error]
        puts ""
      end
    end

    if failed_conversions.any?
      puts "\n" + "⚠" * 3 + " CONVERSION ISSUES " + "⚠" * 3
      failed_conversions.each do |failed|
        puts "  Blob #{failed[:id]} (#{failed[:filename]})"
        puts "    Reason: #{failed[:reason]}" if failed[:reason]
        puts "    Error: #{failed[:error]}" if failed[:error]
        puts ""
      end
    end

    # Next steps
    puts "\n" + "🚀" * 3 + " NEXT STEPS " + "🚀" * 3

    if success_rate >= 95
      puts "✅ Migration highly successful!"
      puts ""
      puts "Your system is now ready for hybrid storage:"
      puts "  • All images have local copies"
      puts "  • Blobs use hybrid service (local first, cloud fallback)"
      puts "  • New uploads will save to both local and cloud"
      puts ""
      puts "To eventually remove DigitalOcean:"
      puts "  1. Test thoroughly that all images load correctly"
      puts "  2. Monitor for a few days to ensure stability"
      puts "  3. Update config/environments/production.rb:"
      puts "     config.active_storage.service = :local_production"
      puts "  4. Run: rails images:convert_all_to_local_only"
      puts "  5. Remove DigitalOcean credentials and configuration"
    elsif success_rate >= 80
      puts "⚠️  Migration mostly successful but needs attention"
      puts ""
      puts "Fix remaining issues:"
      puts "  • Re-run: rails images:retry_failed_downloads"
      puts "  • Check logs for specific errors"
      puts "  • Manual investigation may be needed for some files"
    else
      puts "❌ Migration needs significant attention"
      puts ""
      puts "Many files failed to migrate. Check:"
      puts "  • DigitalOcean credentials and connectivity"
      puts "  • Disk space on local storage"
      puts "  • File permissions on storage directory"
      puts "  • Network connectivity to DigitalOcean"
    end

    puts "\n" + "=" * 60
  end

  desc "Convert all hybrid blobs to local-only (final step before removing cloud)"
  task convert_all_to_local_only: :environment do
    puts "Converting all blobs to local-only storage..."
    puts "⚠️  WARNING: This will remove cloud fallback capability!"
    puts ""

    hybrid_blobs = ActiveStorage::Blob.where(service_name: 'hybrid')

    puts "Found #{hybrid_blobs.count} hybrid blobs to convert"

    # Verify all have local storage first
    missing_local = []
    hybrid_blobs.find_each do |blob|
      local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
      unless File.exist?(local_path) && File.size(local_path) == blob.byte_size
        missing_local << blob
      end
    end

    if missing_local.any?
      puts "❌ Cannot proceed! #{missing_local.count} blobs are missing local files:"
      missing_local.first(10).each do |blob|
        puts "  - #{blob.filename} (#{blob.key[0..7]}...)"
      end
      puts "  ... and #{missing_local.count - 10} more" if missing_local.count > 10
      puts ""
      puts "Run 'rails images:complete_hybrid_migration' first to ensure all files are local"
      return
    end

    puts "✅ All hybrid blobs have local storage. Proceeding with conversion..."

    updated_count = 0
    hybrid_blobs.find_each do |blob|
      blob.update!(service_name: 'local_production')
      updated_count += 1
      puts "  ✓ Converted #{blob.filename} to local_production"
    end

    puts "\nConversion complete!"
    puts "  Converted #{updated_count} blobs to local_production"
    puts ""
    puts "Final service distribution:"
    ActiveStorage::Blob.group(:service_name).count.each do |service, count|
      puts "  #{service}: #{count} blobs"
    end
    puts ""
    puts "🎉 You can now safely remove DigitalOcean configuration!"
  end

  desc "Retry downloading failed images from previous migration"
  task retry_failed_downloads: :environment do
    puts "Retrying failed downloads..."

    retried_count = 0
    success_count = 0
    still_failed_count = 0

    ActiveStorage::Blob.find_each do |blob|
      local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)

      # Skip if already exists with correct size
      next if File.exist?(local_path) && File.size(local_path) == blob.byte_size

      puts "  → Retrying: #{blob.filename}"
      retried_count += 1

      FileUtils.mkdir_p(File.dirname(local_path))

      if download_blob_to_local(blob, local_path)
        puts "    ✓ Success"
        success_count += 1
      else
        puts "    ✗ Still failed"
        still_failed_count += 1
      end
    end

    puts "\nRetry Summary:"
    puts "  Attempted: #{retried_count}"
    puts "  Succeeded: #{success_count}"
    puts "  Still failed: #{still_failed_count}"
  end

  private

  def download_blob_to_local(blob, local_path)
    begin
      # Remove any existing partial file
      File.delete(local_path) if File.exist?(local_path)

      # Get the appropriate service for this blob
      service = case blob.service_name
                when 'digitalocean'
                  ActiveStorage::Service.configure(:digitalocean, Rails.application.config.active_storage.service_configurations)
                when 'hybrid'
                  # For hybrid, try to get the cloud service
                  hybrid_service = ActiveStorage::Service.configure(:hybrid, Rails.application.config.active_storage.service_configurations)
                  hybrid_service.respond_to?(:cloud_service) ? hybrid_service.cloud_service : hybrid_service
                when 'local', 'local_production'
                  # Already local, try to copy from existing location
                  existing_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
                  if File.exist?(existing_path)
                    FileUtils.cp(existing_path, local_path)
                    return true
                  else
                    return false
                  end
                else
                  # Try digitalocean as fallback
                  ActiveStorage::Service.configure(:digitalocean, Rails.application.config.active_storage.service_configurations)
                end

      # Download the file
      File.open(local_path, 'wb') do |file|
        service.download(blob.key) { |chunk| file.write(chunk) }
      end

      # Verify the download
      if File.exist?(local_path) && File.size(local_path) == blob.byte_size
        return true
      else
        File.delete(local_path) if File.exist?(local_path)
        return false
      end

    rescue => e
      # Clean up on failure
      File.delete(local_path) if File.exist?(local_path)
      Rails.logger.error("Failed to download blob #{blob.id}: #{e.message}")
      return false
    end
  end

  def human_size(bytes)
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    size = bytes.to_f
    unit_index = 0

    while size >= 1024 && unit_index < units.length - 1
      size /= 1024
      unit_index += 1
    end

    "#{size.round(2)} #{units[unit_index]}"
  end
end
