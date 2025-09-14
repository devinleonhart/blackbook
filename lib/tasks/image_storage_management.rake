# frozen_string_literal: true

namespace :images do
  desc 'Diagnose image storage status and provide comprehensive report'
  task diagnose: :environment do
    puts "🔍 Image Storage Diagnostic Report"
    puts "=" * 80
    puts "Generated at: #{Time.current}"
    puts

    # Initialize counters
    total_images = 0
    local_only = 0
    cloud_only = 0
    both_storages = 0
    missing_both = 0
    local_as_active_storage = 0
    local_as_descriptive = 0
    size_mismatches = 0

    # Storage paths tracking
    orphaned_active_storage_files = []
    orphaned_descriptive_files = []

    # Error tracking
    errors = []

    puts "📊 Analyzing Image Models..."

    Image.includes(:image_file_attachment, :image_file_blob, :universe, :characters).find_each do |image|
      total_images += 1

      begin
        # Get storage status
        status = image.storage_status
        blob = image.image_file.blob

        # Check local storage in both locations
        local_active_storage_exists = false
        local_descriptive_exists = false

        if blob
          # Check Active Storage path
          active_storage_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
          if File.exist?(active_storage_path)
            local_active_storage_exists = true
            local_as_active_storage += 1

            # Check file size
            if File.size(active_storage_path) != blob.byte_size
              size_mismatches += 1
              errors << "Image #{image.id}: Active Storage file size mismatch (expected: #{blob.byte_size}, actual: #{File.size(active_storage_path)})"
            end
          end

          # Check descriptive filename path
          descriptive_filename = image.get_or_generate_local_filename
          if descriptive_filename
            descriptive_path = Rails.root.join("storage", "descriptive",
                                             Digest::MD5.hexdigest(descriptive_filename)[0..1],
                                             Digest::MD5.hexdigest(descriptive_filename)[2..3],
                                             descriptive_filename)
            if File.exist?(descriptive_path)
              local_descriptive_exists = true
              local_as_descriptive += 1

              # Check file size
              if File.size(descriptive_path) != blob.byte_size
                size_mismatches += 1
                errors << "Image #{image.id}: Descriptive file size mismatch (expected: #{blob.byte_size}, actual: #{File.size(descriptive_path)})"
              end
            end
          end
        end

        # Categorize storage status
        has_local = local_active_storage_exists || local_descriptive_exists
        has_cloud = status[:cloud]

        if has_local && has_cloud
          both_storages += 1
        elsif has_local && !has_cloud
          local_only += 1
        elsif !has_local && has_cloud
          cloud_only += 1
        else
          missing_both += 1
          errors << "Image #{image.id}: Missing from both storages!"
        end

        # Report progress every 100 images
        puts "  Processed #{total_images} images..." if total_images % 100 == 0

      rescue => e
        errors << "Image #{image.id}: Error during analysis - #{e.message}"
      end
    end

    puts
    puts "🔍 Scanning for Orphaned Files..."

    # Scan Active Storage directory for orphaned files
    active_storage_path = Rails.root.join("storage")
    if Dir.exist?(active_storage_path)
      Dir.glob(File.join(active_storage_path, "*", "*", "*")).each do |file_path|
        next if File.directory?(file_path)
        next if file_path.include?("/descriptive/") # Skip descriptive files

        blob_key = File.basename(file_path)

        # Check if this blob key exists in active_storage_blobs
        unless ActiveStorage::Blob.exists?(key: blob_key)
          orphaned_active_storage_files << file_path
        end
      end
    end

    # Scan descriptive files directory for orphaned files
    descriptive_path = Rails.root.join("storage", "descriptive")
    if Dir.exist?(descriptive_path)
      Dir.glob(File.join(descriptive_path, "**", "*")).each do |file_path|
        next if File.directory?(file_path)

        filename = File.basename(file_path)

        # Check if any image would generate this filename
        found_matching_image = false
        Image.includes(:image_file_blob, :universe, :characters).find_each do |image|
          if image.get_or_generate_local_filename == filename
            found_matching_image = true
            break
          end
        end

        unless found_matching_image
          orphaned_descriptive_files << file_path
        end
      end
    end

    puts
    puts "📋 DIAGNOSTIC SUMMARY"
    puts "=" * 80
    puts "Total Images in Database: #{total_images}"
    puts
    puts "Storage Distribution:"
    puts "  📁 Local Only:          #{local_only} (#{percentage(local_only, total_images)}%)"
    puts "  ☁️  Cloud Only:          #{cloud_only} (#{percentage(cloud_only, total_images)}%)"
    puts "  🔄 Both Storages:       #{both_storages} (#{percentage(both_storages, total_images)}%)"
    puts "  ❌ Missing Both:        #{missing_both} (#{percentage(missing_both, total_images)}%)"
    puts
    puts "Local Storage Details:"
    puts "  📂 Active Storage Files: #{local_as_active_storage}"
    puts "  📝 Descriptive Files:   #{local_as_descriptive}"
    puts "  ⚠️  Size Mismatches:     #{size_mismatches}"
    puts
    puts "Orphaned Files:"
    puts "  🗑️  Active Storage:      #{orphaned_active_storage_files.size} files"
    puts "  🗑️  Descriptive:         #{orphaned_descriptive_files.size} files"

    if errors.any?
      puts
      puts "❌ ERRORS ENCOUNTERED (#{errors.size}):"
      errors.first(10).each { |error| puts "  • #{error}" }
      puts "  ... and #{errors.size - 10} more errors" if errors.size > 10
    end

    puts
    puts "💾 STORAGE RECOMMENDATIONS:"

    if cloud_only > 0
      puts "  🔽 #{cloud_only} images need to be downloaded from cloud to local"
    end

    if local_only > 0
      puts "  🔼 #{local_only} images need to be uploaded from local to cloud"
    end

    if missing_both > 0
      puts "  🚨 #{missing_both} images are missing from BOTH storages - CRITICAL!"
    end

    if orphaned_active_storage_files.any? || orphaned_descriptive_files.any?
      puts "  🧹 #{orphaned_active_storage_files.size + orphaned_descriptive_files.size} orphaned files can be cleaned up"
    end

    if size_mismatches > 0
      puts "  🔧 #{size_mismatches} files have size mismatches and need re-sync"
    end

    puts
    puts "🎯 NEXT STEPS:"
    puts "  1. Run 'rake images:mirror_all' to sync all images between storages"
    puts "  2. Run 'rake images:cleanup_orphaned' to remove orphaned files"
    puts "  3. Run 'rake images:regenerate_thumbnails' to regenerate all thumbnails"

    puts
    puts "✅ Diagnostic complete!"
  end

  desc 'Mirror all images between DigitalOcean and local storage'
  task mirror_all: :environment do
    puts "🔄 Mirroring All Images Between Storages"
    puts "=" * 80
    puts "Started at: #{Time.current}"
    puts

    total_images = 0
    success_count = 0
    error_count = 0
    skip_count = 0

    errors = []

    # Configure cloud service for direct access
    cloud_service = ActiveStorage::Service.configure(:digitalocean, Rails.application.config.active_storage.service_configurations)

    puts "📥 Processing images for mirroring..."

    Image.includes(:image_file_attachment, :image_file_blob, :universe, :characters).find_each do |image|
      total_images += 1

      begin
        next unless image.image_file.attached?
        blob = image.image_file.blob

        # Check current storage status
        has_local_active = false
        has_local_descriptive = false
        has_cloud = false

        # Check Active Storage local path
        active_storage_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
        if File.exist?(active_storage_path) && File.size(active_storage_path) == blob.byte_size
          has_local_active = true
        end

        # Check descriptive local path
        descriptive_filename = image.get_or_generate_local_filename
        descriptive_path = nil
        if descriptive_filename
          hash = Digest::MD5.hexdigest(descriptive_filename)
          descriptive_path = Rails.root.join("storage", "descriptive", hash[0..1], hash[2..3], descriptive_filename)
          if File.exist?(descriptive_path) && File.size(descriptive_path) == blob.byte_size
            has_local_descriptive = true
          end
        end

        # Check cloud storage
        begin
          has_cloud = cloud_service.exist?(blob.key)
        rescue => e
          errors << "Image #{image.id}: Cannot check cloud status - #{e.message}"
          error_count += 1
          next
        end

        has_local = has_local_active || has_local_descriptive

        # Skip if already mirrored
        if has_local && has_cloud
          skip_count += 1
          puts "  ✅ Image #{image.id}: Already mirrored" if total_images % 50 == 1
          next
        end

        # Case 1: Local only - upload to cloud
        if has_local && !has_cloud
          puts "  🔼 Image #{image.id}: Uploading to cloud..."

          # Get local file content
          local_file_path = has_local_active ? active_storage_path : descriptive_path

          File.open(local_file_path, 'rb') do |file|
            cloud_service.upload(blob.key, file, checksum: blob.checksum)
          end

          # Verify upload
          if cloud_service.exist?(blob.key)
            success_count += 1
            puts "    ✅ Successfully uploaded to cloud"
          else
            error_count += 1
            errors << "Image #{image.id}: Upload verification failed"
          end

        # Case 2: Cloud only - download to local
        elsif !has_local && has_cloud
          puts "  🔽 Image #{image.id}: Downloading to local..."

          # Download to both Active Storage and descriptive paths
          temp_file = Tempfile.new(['mirror', File.extname(blob.filename.to_s)])

          begin
            # Download from cloud
            cloud_service.download(blob.key) do |chunk|
              temp_file.write(chunk)
            end
            temp_file.rewind

            # Save to Active Storage path
            FileUtils.mkdir_p(File.dirname(active_storage_path))
            FileUtils.cp(temp_file.path, active_storage_path)

            # Save to descriptive path if possible
            if descriptive_path
              FileUtils.mkdir_p(File.dirname(descriptive_path))
              FileUtils.cp(temp_file.path, descriptive_path)
            end

            # Verify downloads
            active_ok = File.exist?(active_storage_path) && File.size(active_storage_path) == blob.byte_size
            descriptive_ok = !descriptive_path || (File.exist?(descriptive_path) && File.size(descriptive_path) == blob.byte_size)

            if active_ok && descriptive_ok
              success_count += 1
              puts "    ✅ Successfully downloaded to local"
            else
              error_count += 1
              errors << "Image #{image.id}: Download verification failed"
            end

          ensure
            temp_file.close
            temp_file.unlink
          end

        # Case 3: Missing from both storages
        else
          error_count += 1
          errors << "Image #{image.id}: Missing from BOTH storages - cannot mirror!"
        end

      rescue => e
        error_count += 1
        errors << "Image #{image.id}: Error during mirroring - #{e.message}"
      end

      # Progress report
      puts "  📊 Processed #{total_images} images (#{success_count} success, #{skip_count} skipped, #{error_count} errors)" if total_images % 100 == 0
    end

    puts
    puts "📋 MIRRORING SUMMARY"
    puts "=" * 80
    puts "Total Images Processed: #{total_images}"
    puts "✅ Successfully Mirrored: #{success_count}"
    puts "⏭️  Already Mirrored: #{skip_count}"
    puts "❌ Errors: #{error_count}"

    if errors.any?
      puts
      puts "❌ ERRORS ENCOUNTERED:"
      errors.first(10).each { |error| puts "  • #{error}" }
      puts "  ... and #{errors.size - 10} more errors" if errors.size > 10
    end

    puts
    puts "✅ Mirroring complete at #{Time.current}!"
  end

  desc 'Clean up orphaned local files not associated with any image models'
  task cleanup_orphaned: :environment do
    puts "🧹 Cleaning Up Orphaned Local Files"
    puts "=" * 80
    puts "Started at: #{Time.current}"
    puts

    deleted_active_storage = 0
    deleted_descriptive = 0
    deleted_size = 0
    errors = []

    # Track valid blob keys and descriptive filenames
    valid_blob_keys = Set.new
    valid_descriptive_filenames = Set.new

    puts "📋 Building index of valid files..."

    # Collect all valid blob keys
    ActiveStorage::Blob.find_each do |blob|
      valid_blob_keys << blob.key
    end

    # Collect all valid descriptive filenames
    Image.includes(:image_file_blob, :universe, :characters).find_each do |image|
      filename = image.get_or_generate_local_filename
      valid_descriptive_filenames << filename if filename
    end

    puts "  📊 Found #{valid_blob_keys.size} valid blob keys"
    puts "  📊 Found #{valid_descriptive_filenames.size} valid descriptive filenames"
    puts

    # Clean up Active Storage directory
    puts "🗑️  Scanning Active Storage directory..."
    active_storage_path = Rails.root.join("storage")

    if Dir.exist?(active_storage_path)
      Dir.glob(File.join(active_storage_path, "*", "*", "*")).each do |file_path|
        next if File.directory?(file_path)
        next if file_path.include?("/descriptive/") # Skip descriptive files directory

        blob_key = File.basename(file_path)

        unless valid_blob_keys.include?(blob_key)
          begin
            file_size = File.size(file_path)
            File.delete(file_path)
            deleted_active_storage += 1
            deleted_size += file_size
            puts "  🗑️  Deleted orphaned Active Storage file: #{blob_key}"
          rescue => e
            errors << "Failed to delete Active Storage file #{file_path}: #{e.message}"
          end
        end
      end
    end

    # Clean up descriptive files directory
    puts "🗑️  Scanning descriptive files directory..."
    descriptive_path = Rails.root.join("storage", "descriptive")

    if Dir.exist?(descriptive_path)
      Dir.glob(File.join(descriptive_path, "**", "*")).each do |file_path|
        next if File.directory?(file_path)

        filename = File.basename(file_path)

        unless valid_descriptive_filenames.include?(filename)
          begin
            file_size = File.size(file_path)
            File.delete(file_path)
            deleted_descriptive += 1
            deleted_size += file_size
            puts "  🗑️  Deleted orphaned descriptive file: #{filename}"
          rescue => e
            errors << "Failed to delete descriptive file #{file_path}: #{e.message}"
          end
        end
      end
    end

    # Clean up empty directories
    puts "🗂️  Cleaning up empty directories..."

    [active_storage_path, descriptive_path].each do |base_path|
      next unless Dir.exist?(base_path)

      Dir.glob(File.join(base_path, "**", "*")).select { |d| File.directory?(d) }.reverse_each do |dir|
        begin
          if Dir.empty?(dir) && dir != base_path.to_s
            Dir.rmdir(dir)
            puts "  📁 Removed empty directory: #{dir.sub(Rails.root.to_s, '')}"
          end
        rescue => e
          # Ignore errors when removing directories (might not be empty due to hidden files)
        end
      end
    end

    puts
    puts "📋 CLEANUP SUMMARY"
    puts "=" * 80
    puts "🗑️  Active Storage Files Deleted: #{deleted_active_storage}"
    puts "🗑️  Descriptive Files Deleted: #{deleted_descriptive}"
    puts "💾 Total Space Freed: #{format_file_size(deleted_size)}"

    if errors.any?
      puts
      puts "❌ ERRORS ENCOUNTERED (#{errors.size}):"
      errors.first(10).each { |error| puts "  • #{error}" }
      puts "  ... and #{errors.size - 10} more errors" if errors.size > 10
    end

    puts
    puts "✅ Cleanup complete at #{Time.current}!"
  end

  desc 'Regenerate all image thumbnails'
  task regenerate_thumbnails: :environment do
    puts "🖼️  Regenerating All Image Thumbnails"
    puts "=" * 80
    puts "Started at: #{Time.current}"
    puts

    total_images = 0
    success_count = 0
    error_count = 0
    errors = []

    # Common thumbnail sizes used in the application
    thumbnail_sizes = [
      [100, 100],   # Small thumbnails
      [300, 300],   # Medium thumbnails
      [800, 600],   # Large previews
      [1200, 900]   # Full size previews
    ]

    puts "🔧 Regenerating thumbnails for #{thumbnail_sizes.size} different sizes..."
    puts "   Sizes: #{thumbnail_sizes.map { |w, h| "#{w}x#{h}" }.join(', ')}"
    puts

    Image.includes(:image_file_attachment, :image_file_blob).find_each do |image|
      total_images += 1

      begin
        next unless image.image_file.attached?

        # Skip GIFs as they don't need thumbnail variants
        if image.image_file.filename.extension == "gif"
          puts "  ⏭️  Image #{image.id}: Skipping GIF"
          success_count += 1
          next
        end

        puts "  🖼️  Image #{image.id}: Generating thumbnails..."

        # Generate each thumbnail size
        thumbnail_sizes.each do |width, height|
          begin
            variant = image.image_file.variant(resize_to_limit: [width, height])

            # Force generation by accessing the variant
            variant.processed

            puts "    ✅ Generated #{width}x#{height} thumbnail"

          rescue => e
            errors << "Image #{image.id}: Failed to generate #{width}x#{height} thumbnail - #{e.message}"
            puts "    ❌ Failed #{width}x#{height} thumbnail"
          end
        end

        success_count += 1

      rescue => e
        error_count += 1
        errors << "Image #{image.id}: Error during thumbnail generation - #{e.message}"
        puts "  ❌ Image #{image.id}: #{e.message}"
      end

      # Progress report
      puts "  📊 Processed #{total_images} images (#{success_count} success, #{error_count} errors)" if total_images % 50 == 0
    end

    # Optionally clean up old/unused variants
    puts
    puts "🧹 Cleaning up unused variant records..."

    deleted_variants = 0
    ActiveStorage::VariantRecord.find_each do |variant_record|
      begin
        # Check if the variant blob still exists
        unless variant_record.image.blob.present?
          variant_record.destroy!
          deleted_variants += 1
        end
      rescue => e
        # Ignore errors - variant might be in use
      end
    end

    puts "  🗑️  Deleted #{deleted_variants} orphaned variant records"

    puts
    puts "📋 THUMBNAIL REGENERATION SUMMARY"
    puts "=" * 80
    puts "Total Images Processed: #{total_images}"
    puts "✅ Successfully Processed: #{success_count}"
    puts "❌ Errors: #{error_count}"
    puts "🗑️  Orphaned Variants Cleaned: #{deleted_variants}"

    if errors.any?
      puts
      puts "❌ ERRORS ENCOUNTERED (#{errors.size}):"
      errors.first(10).each { |error| puts "  • #{error}" }
      puts "  ... and #{errors.size - 10} more errors" if errors.size > 10
    end

    puts
    puts "✅ Thumbnail regeneration complete at #{Time.current}!"
  end

  desc 'Complete storage migration workflow (diagnose -> mirror -> cleanup -> thumbnails)'
  task complete_migration: :environment do
    puts "🚀 Starting Complete Image Storage Migration"
    puts "=" * 80
    puts

    puts "1️⃣  Running diagnostics..."
    Rake::Task['images:diagnose'].invoke

    puts "\n" + "=" * 80
    puts "2️⃣  Mirroring all images..."
    Rake::Task['images:mirror_all'].invoke

    puts "\n" + "=" * 80
    puts "3️⃣  Cleaning up orphaned files..."
    Rake::Task['images:cleanup_orphaned'].invoke

    puts "\n" + "=" * 80
    puts "4️⃣  Regenerating thumbnails..."
    Rake::Task['images:regenerate_thumbnails'].invoke

    puts "\n" + "=" * 80
    puts "🎉 Complete migration workflow finished!"
    puts "   Run 'rake images:diagnose' again to verify everything is working correctly."
  end

  private

  def percentage(part, total)
    return 0 if total.zero?
    ((part.to_f / total) * 100).round(1)
  end

  def format_file_size(size)
    return "0 B" if size.zero?

    units = %w[B KB MB GB TB]
    base = 1024
    exp = (Math.log(size) / Math.log(base)).floor
    exp = [exp, units.length - 1].min

    "%.1f %s" % [size.to_f / base**exp, units[exp]]
  end
end
