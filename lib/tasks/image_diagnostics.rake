# frozen_string_literal: true

namespace :images do
  desc "Detailed diagnostics of where images are actually being served from"
  task diagnose: :environment do
    puts "Image Storage Diagnostics"
    puts "=" * 60
    puts "This will show exactly where your images are being served from"
    puts "=" * 60

    # Current configuration
    puts "\nCURRENT CONFIGURATION:"
    puts "Environment: #{Rails.env}"
    puts "Active Storage Service: #{Rails.application.config.active_storage.service}"

    # Service details
    service_config = Rails.application.config.active_storage.service_configurations
    puts "\nConfigured Services:"
    service_config.each do |name, config|
      puts "  #{name}: #{config['service']}"
      if config['service'] == 'Disk'
        puts "    Root: #{config['root']}"
      elsif config['service'] == 'S3'
        puts "    Endpoint: #{config['endpoint']}"
        puts "    Bucket: #{config['bucket']}"
      end
    end

    # Check what service is actually being used
    current_service = ActiveStorage::Blob.service
    puts "\nActual Service in Use: #{current_service.class.name}"
    if current_service.respond_to?(:local_service)
      puts "  Local Service: #{current_service.local_service.class.name}"
      puts "  Cloud Service: #{current_service.cloud_service.class.name}"
    end

    # Sample Image Analysis
    puts "\n" + "=" * 60
    puts "SAMPLE IMAGE ANALYSIS (First 10 images)"
    puts "=" * 60

    sample_images = Image.includes({ image_file_attachment: :blob }).limit(10)

    if sample_images.empty?
      puts "No Image models found!"
      return
    end

    sample_images.each do |image|
      next unless image.image_file.attached?

      blob = image.image_file.blob
      puts "\nImage ID: #{image.id}"
      puts "  Filename: #{blob.filename}"
      puts "  Blob ID: #{blob.id}"
      puts "  Service Name: #{blob.service_name}"
      puts "  Key: #{blob.key}"
      puts "  Size: #{human_size(blob.byte_size)}"

      # Check local storage paths
      standard_local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
      puts "  Standard Local Path: #{standard_local_path}"
      puts "    Exists: #{File.exist?(standard_local_path)}"
      if File.exist?(standard_local_path)
        puts "    Size: #{human_size(File.size(standard_local_path))}"
        puts "    Size Match: #{File.size(standard_local_path) == blob.byte_size}"
      end

      # Check descriptive filename path (if using descriptive naming)
      if image.respond_to?(:local_file_path) && image.local_file_path
        descriptive_path = image.local_file_path
        puts "  Descriptive Path: #{descriptive_path}"
        puts "    Exists: #{File.exist?(descriptive_path)}"
        if File.exist?(descriptive_path)
          puts "    Size: #{human_size(File.size(descriptive_path))}"
          puts "    Size Match: #{File.size(descriptive_path) == blob.byte_size}"
        end
      end

      # Test actual URL generation
      begin
        url = Rails.application.routes.url_helpers.url_for(image.image_file)
        puts "  Generated URL: #{url[0..80]}#{url.length > 80 ? '...' : ''}"
      rescue => e
        puts "  URL Generation Error: #{e.message}"
      end

      # Test if we can actually access the file
      begin
        # Try to read the first few bytes
        image.image_file.download do |chunk|
          puts "  ✓ File accessible (first chunk: #{chunk.length} bytes)"
          break # Only read first chunk
        end
      rescue => e
        puts "  ✗ File access failed: #{e.message}"
      end
    end

    # Storage Service Deep Dive
    puts "\n" + "=" * 60
    puts "STORAGE SERVICE DEEP DIVE"
    puts "=" * 60

    # Test service behavior with a sample blob
    sample_blob = ActiveStorage::Blob.first
    if sample_blob
      puts "\nTesting with blob: #{sample_blob.filename} (#{sample_blob.key})"

      # Test existence check
      begin
        exists = sample_blob.service.exist?(sample_blob.key)
        puts "  Service reports file exists: #{exists}"
      rescue => e
        puts "  Service existence check failed: #{e.message}"
      end

      # If hybrid service, test both components
      if sample_blob.service.respond_to?(:local_service) && sample_blob.service.respond_to?(:cloud_service)
        puts "\n  HYBRID SERVICE BREAKDOWN:"

        # Test local service
        begin
          local_exists = sample_blob.service.local_service.exist?(sample_blob.key)
          puts "    Local service exists: #{local_exists}"
        rescue => e
          puts "    Local service check failed: #{e.message}"
        end

        # Test cloud service
        begin
          cloud_exists = sample_blob.service.cloud_service.exist?(sample_blob.key)
          puts "    Cloud service exists: #{cloud_exists}"
        rescue => e
          puts "    Cloud service check failed: #{e.message}"
        end
      end
    end

    # Blob Service Distribution
    puts "\n" + "=" * 60
    puts "BLOB SERVICE DISTRIBUTION"
    puts "=" * 60

    total_blobs = ActiveStorage::Blob.count
    puts "Total blobs: #{total_blobs}"

    if total_blobs > 0
      ActiveStorage::Blob.group(:service_name).count.each do |service, count|
        percentage = ((count.to_f / total_blobs) * 100).round(1)
        puts "  #{service}: #{count} blobs (#{percentage}%)"
      end
    end

    # File System Reality Check
    puts "\n" + "=" * 60
    puts "FILE SYSTEM REALITY CHECK"
    puts "=" * 60

    storage_root = Rails.root.join("storage")
    if Dir.exist?(storage_root)
      # Count actual files in storage
      actual_files = Dir.glob(storage_root.join("**", "*")).select { |f| File.file?(f) }
      total_size = actual_files.sum { |f| File.size(f) }

      puts "Storage directory: #{storage_root}"
      puts "Actual files on disk: #{actual_files.count}"
      puts "Total disk usage: #{human_size(total_size)}"

      # Sample some actual files
      puts "\nSample files on disk:"
      actual_files.first(5).each do |file|
        relative_path = Pathname.new(file).relative_path_from(storage_root)
        key = File.basename(file)
        blob = ActiveStorage::Blob.find_by(key: key)

        puts "  #{relative_path}"
        puts "    Size: #{human_size(File.size(file))}"
        puts "    Has blob record: #{blob ? 'Yes' : 'No'}"
        if blob
          puts "    Blob service: #{blob.service_name}"
          puts "    Size match: #{File.size(file) == blob.byte_size}"
        end
      end
    else
      puts "Storage directory does not exist: #{storage_root}"
    end

    # Recommendations
    puts "\n" + "=" * 60
    puts "ANALYSIS & RECOMMENDATIONS"
    puts "=" * 60

    working_images = sample_images.select do |image|
      begin
        image.image_file.download { |chunk| break }
        true
      rescue
        false
      end
    end

    puts "Working images in sample: #{working_images.count}/#{sample_images.count}"

    if working_images.count == sample_images.count
      puts "✅ All sampled images are working!"
      puts "\nYour images are being served from:"

      # Determine where images are actually coming from
      if sample_blob&.service.respond_to?(:local_service)
        local_path = Rails.root.join("storage", sample_blob.key[0..1], sample_blob.key[2..3], sample_blob.key)
        if File.exist?(local_path)
          puts "  ✓ Local storage (primary)"
        else
          puts "  ✓ Cloud storage (fallback)"
        end
      else
        case sample_blob&.service_name
        when 'local', 'local_production'
          puts "  ✓ Local storage only"
        when 'digitalocean'
          puts "  ✓ DigitalOcean cloud storage only"
        when 'hybrid'
          puts "  ✓ Hybrid service (should check local first, then cloud)"
        end
      end

      puts "\nNo immediate action needed, but run storage audit to optimize:"
      puts "  rails images:storage_audit"
    else
      puts "⚠️  Some images are not working!"
      puts "\nTroubleshoot with:"
      puts "  1. Check service configuration"
      puts "  2. Verify storage credentials"
      puts "  3. Run: rails images:complete_hybrid_migration"
    end

    puts "\n" + "=" * 60
  end

  desc "Test specific image access patterns"
  task :test_image_access, [:image_id] => :environment do |t, args|
    image_id = args[:image_id] || Image.first&.id

    if image_id.nil?
      puts "No image ID provided and no images found"
      puts "Usage: rails images:test_image_access[123]"
      return
    end

    image = Image.find(image_id)
    puts "Testing Image ID: #{image_id}"
    puts "=" * 40

    unless image.image_file.attached?
      puts "❌ No file attached to this image"
      return
    end

    blob = image.image_file.blob
    puts "Blob ID: #{blob.id}"
    puts "Filename: #{blob.filename}"
    puts "Service: #{blob.service_name}"
    puts "Key: #{blob.key}"

    # Test different access methods
    puts "\nAccess Tests:"

    # 1. Direct blob download
    begin
      blob.download do |chunk|
        puts "  ✓ Direct blob download works (#{chunk.length} bytes)"
        break
      end
    rescue => e
      puts "  ✗ Direct blob download failed: #{e.message}"
    end

    # 2. Through image attachment
    begin
      image.image_file.download do |chunk|
        puts "  ✓ Image attachment download works (#{chunk.length} bytes)"
        break
      end
    rescue => e
      puts "  ✗ Image attachment download failed: #{e.message}"
    end

    # 3. URL generation
    begin
      url = Rails.application.routes.url_helpers.url_for(image.image_file)
      puts "  ✓ URL generation works: #{url[0..60]}..."
    rescue => e
      puts "  ✗ URL generation failed: #{e.message}"
    end

    # 4. Service-level checks
    puts "\nService-level checks:"
    begin
      puts "  Service exists check: #{blob.service.exist?(blob.key)}"
    rescue => e
      puts "  ✗ Service exists check failed: #{e.message}"
    end

    # 5. File system check
    local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
    puts "  Local file exists: #{File.exist?(local_path)}"
    if File.exist?(local_path)
      puts "  Local file size: #{human_size(File.size(local_path))}"
      puts "  Size matches blob: #{File.size(local_path) == blob.byte_size}"
    end
  end

  private

  def human_size(bytes)
    return "0 B" if bytes == 0

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
