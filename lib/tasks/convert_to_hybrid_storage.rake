# frozen_string_literal: true

namespace :images do
  desc "Convert all Active Storage blobs to use hybrid storage service"
  task convert_to_hybrid: :environment do
    puts "Converting Active Storage blobs to use hybrid storage service..."
    puts "=" * 60

    # Find all blobs that are not using the hybrid service
    blobs_to_update = ActiveStorage::Blob.where.not(service_name: 'hybrid')
    total_blobs = ActiveStorage::Blob.count

    puts "Total blobs: #{total_blobs}"
    puts "Blobs to convert: #{blobs_to_update.count}"

    if blobs_to_update.count == 0
      puts "✅ All blobs are already using hybrid storage!"
      return
    end

    # Show current distribution
    puts "\nCurrent service distribution:"
    ActiveStorage::Blob.group(:service_name).count.each do |service, count|
      puts "  #{service}: #{count} blobs"
    end

    puts "\nStarting conversion..."
    updated_count = 0
    failed_count = 0
    failed_blobs = []

    blobs_to_update.find_each(batch_size: 50) do |blob|
      begin
        old_service = blob.service_name

        # Check if the blob has a corresponding file in local storage
        local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)

        if File.exist?(local_path)
          # Update the service name to hybrid
          blob.update!(service_name: 'hybrid')
          puts "  ✓ Converted blob #{blob.id} (#{blob.filename}) from '#{old_service}' to 'hybrid'"
          updated_count += 1
        else
          puts "  ⚠ Blob #{blob.id} (#{blob.filename}) missing local file: #{local_path}"
          puts "    Skipping conversion - local file must exist for hybrid storage"
          failed_count += 1
          failed_blobs << {
            id: blob.id,
            filename: blob.filename.to_s,
            key: blob.key,
            old_service: old_service,
            local_path: local_path.to_s
          }
        end

      rescue => e
        puts "  ✗ Failed to convert blob #{blob.id}: #{e.message}"
        failed_count += 1
        failed_blobs << {
          id: blob.id,
          filename: blob&.filename&.to_s || 'unknown',
          error: e.message
        }
      end

      # Progress update every 25 blobs
      if (updated_count + failed_count) % 25 == 0
        puts "Progress: #{updated_count + failed_count}/#{blobs_to_update.count} processed"
      end
    end

    puts "\n" + "=" * 60
    puts "Conversion Summary:"
    puts "  Total blobs: #{total_blobs}"
    puts "  Successfully converted: #{updated_count}"
    puts "  Failed/Skipped: #{failed_count}"

    if failed_count > 0
      success_rate = ((updated_count.to_f / blobs_to_update.count) * 100).round(2)
      puts "  Success rate: #{success_rate}%"
    else
      puts "  Success rate: 100%"
    end

    # Show final distribution
    puts "\nFinal service distribution:"
    ActiveStorage::Blob.group(:service_name).count.each do |service, count|
      puts "  #{service}: #{count} blobs"
    end

    if failed_blobs.any?
      puts "\nFailed/Skipped blobs:"
      failed_blobs.each do |failed|
        puts "  - ID: #{failed[:id]}"
        puts "    Filename: #{failed[:filename]}"
        if failed[:local_path]
          puts "    Missing file: #{failed[:local_path]}"
          puts "    Suggestion: Run 'rails images:download_missing_files' to restore from cloud"
        end
        puts "    Error: #{failed[:error]}" if failed[:error]
        puts ""
      end
    end

    if updated_count > 0
      puts "\n✅ Conversion complete!"
      puts "Your images should now work with hybrid storage."
      puts "The system will:"
      puts "  - Try to serve images from local storage first"
      puts "  - Fallback to cloud storage if local file is missing"
      puts "  - Save new uploads to both local and cloud"
    end

    puts "=" * 60
  end

  desc "Download missing local files for blobs that need them"
  task download_missing_files: :environment do
    puts "Downloading missing local files for hybrid storage..."

    downloaded_count = 0
    failed_count = 0

    ActiveStorage::Blob.where(service_name: 'hybrid').find_each do |blob|
      local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)

      next if File.exist?(local_path) && File.size(local_path) == blob.byte_size

      puts "Downloading #{blob.filename} (#{blob.key})..."

      begin
        # Create directory structure
        FileUtils.mkdir_p(File.dirname(local_path))

        # Try to download from cloud storage
        cloud_service = ActiveStorage::Service.configure(:digitalocean, Rails.application.config.active_storage.service_configurations)

        File.open(local_path, 'wb') do |file|
          cloud_service.download(blob.key) { |chunk| file.write(chunk) }
        end

        if File.exist?(local_path) && File.size(local_path) == blob.byte_size
          puts "  ✓ Downloaded successfully"
          downloaded_count += 1
        else
          raise "File size mismatch after download"
        end

      rescue => e
        puts "  ✗ Failed to download: #{e.message}"
        failed_count += 1
        # Clean up partial file
        File.delete(local_path) if File.exist?(local_path)
      end
    end

    puts "\nDownload Summary:"
    puts "  Downloaded: #{downloaded_count}"
    puts "  Failed: #{failed_count}"
  end

  desc "Verify all hybrid blobs have both local and cloud storage"
  task verify_hybrid_storage: :environment do
    puts "Verifying hybrid storage for all blobs..."

    hybrid_blobs = ActiveStorage::Blob.where(service_name: 'hybrid')

    puts "Checking #{hybrid_blobs.count} hybrid blobs..."

    local_ok = 0
    local_missing = 0
    cloud_ok = 0
    cloud_missing = 0

    hybrid_blobs.find_each do |blob|
      # Check local storage
      local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
      if File.exist?(local_path) && File.size(local_path) == blob.byte_size
        local_ok += 1
      else
        local_missing += 1
        puts "  ⚠ Local missing: #{blob.filename} (#{blob.key})"
      end

      # Check cloud storage
      begin
        cloud_service = ActiveStorage::Service.configure(:digitalocean, Rails.application.config.active_storage.service_configurations)
        if cloud_service.exist?(blob.key)
          cloud_ok += 1
        else
          cloud_missing += 1
          puts "  ⚠ Cloud missing: #{blob.filename} (#{blob.key})"
        end
      rescue => e
        cloud_missing += 1
        puts "  ✗ Cloud check failed for #{blob.filename}: #{e.message}"
      end
    end

    puts "\nVerification Results:"
    puts "  Local storage: #{local_ok} OK, #{local_missing} missing"
    puts "  Cloud storage: #{cloud_ok} OK, #{cloud_missing} missing"

    if local_missing > 0
      puts "\nTo fix missing local files, run:"
      puts "  rails images:download_missing_files"
    end

    if local_ok == hybrid_blobs.count && cloud_ok == hybrid_blobs.count
      puts "\n✅ All hybrid blobs have both local and cloud storage!"
    end
  end
end
