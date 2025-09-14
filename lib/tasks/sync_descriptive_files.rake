# frozen_string_literal: true

namespace :images do
  desc "Sync descriptive filename files to standard ActiveStorage paths and convert to hybrid"
  task sync_descriptive_to_standard_paths: :environment do
    puts "Syncing Descriptive Files to Standard ActiveStorage Paths"
    puts "=" * 70
    puts "This will copy your existing descriptive files to standard paths"
    puts "and convert blob service names to hybrid for proper fallback"
    puts "=" * 70

    total_blobs = ActiveStorage::Blob.count
    copied_count = 0
    converted_count = 0
    already_standard_count = 0
    missing_descriptive_count = 0
    failed_count = 0
    failed_items = []

    puts "Total blobs to process: #{total_blobs}"

    # Process all blobs
    ActiveStorage::Blob.find_each(batch_size: 50) do |blob|
      begin
        # Standard ActiveStorage path
        standard_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)

        # Check if already exists in standard location
        if File.exist?(standard_path) && File.size(standard_path) == blob.byte_size
          puts "  ✓ Already in standard path: #{blob.filename} (#{blob.key[0..7]}...)"
          already_standard_count += 1

          # Still convert service name to hybrid if needed
          if blob.service_name != 'hybrid'
            blob.update!(service_name: 'hybrid')
            converted_count += 1
          end
          next
        end

        # Try to find the descriptive file
        descriptive_file = find_descriptive_file_for_blob(blob)

        if descriptive_file && File.exist?(descriptive_file) && File.size(descriptive_file) == blob.byte_size
          puts "  → Copying: #{blob.filename} (#{human_size(blob.byte_size)})"
          puts "    From: #{descriptive_file.sub(Rails.root.to_s, '')}"
          puts "    To: #{standard_path.sub(Rails.root.to_s, '')}"

          # Create directory structure
          FileUtils.mkdir_p(File.dirname(standard_path))

          # Copy the file
          FileUtils.cp(descriptive_file, standard_path)

          # Verify the copy
          if File.exist?(standard_path) && File.size(standard_path) == blob.byte_size
            puts "    ✓ Copy successful"
            copied_count += 1

            # Convert to hybrid service
            if blob.service_name != 'hybrid'
              blob.update!(service_name: 'hybrid')
              converted_count += 1
              puts "    ✓ Converted to hybrid service"
            end
          else
            raise "Copy verification failed"
          end

        else
          puts "  ⚠ No descriptive file found: #{blob.filename} (#{blob.key[0..7]}...)"
          missing_descriptive_count += 1
          failed_items << {
            id: blob.id,
            filename: blob.filename.to_s,
            key: blob.key,
            reason: "No descriptive file found",
            expected_descriptive: descriptive_file&.to_s
          }

          # Still try to convert service name if it makes sense
          if blob.service_name != 'hybrid'
            blob.update!(service_name: 'hybrid')
            converted_count += 1
            puts "    ✓ Converted to hybrid service (will use cloud fallback)"
          end
        end

      rescue => e
        puts "  ✗ Failed to process blob #{blob.id} (#{blob.filename}): #{e.message}"
        failed_count += 1
        failed_items << {
          id: blob.id,
          filename: blob.filename&.to_s || 'unknown',
          error: e.message
        }
      end

      # Progress update
      processed = copied_count + already_standard_count + missing_descriptive_count + failed_count
      if processed % 100 == 0
        puts "    Progress: #{processed}/#{total_blobs} processed"
      end
    end

    # Summary
    puts "\n" + "=" * 70
    puts "SYNC COMPLETE"
    puts "=" * 70

    puts "\nResults:"
    puts "  Already in standard paths: #{already_standard_count}"
    puts "  Copied from descriptive: #{copied_count}"
    puts "  Missing descriptive files: #{missing_descriptive_count}"
    puts "  Failed: #{failed_count}"
    puts "  Service names converted to hybrid: #{converted_count}"

    # Calculate storage usage
    total_copied_size = 0
    Dir.glob(Rails.root.join("storage", "*", "*", "*")).each do |file|
      next unless File.file?(file)
      total_copied_size += File.size(file)
    end

    puts "\nStorage usage:"
    puts "  Standard ActiveStorage: #{human_size(total_copied_size)}"

    # Show final service distribution
    puts "\nFinal service distribution:"
    ActiveStorage::Blob.group(:service_name).count.each do |service, count|
      percentage = ((count.to_f / total_blobs) * 100).round(1)
      puts "  #{service}: #{count} blobs (#{percentage}%)"
    end

    # Report issues
    if failed_items.any?
      puts "\n" + "⚠" * 3 + " ISSUES TO REVIEW " + "⚠" * 3
      failed_items.first(10).each do |item|
        puts "  Blob #{item[:id]} (#{item[:filename]})"
        puts "    Reason: #{item[:reason]}" if item[:reason]
        puts "    Error: #{item[:error]}" if item[:error]
        puts "    Expected: #{item[:expected_descriptive]}" if item[:expected_descriptive]
        puts ""
      end
      puts "  ... and #{failed_items.count - 10} more" if failed_items.count > 10
    end

    # Success assessment
    success_rate = total_blobs > 0 ? (((copied_count + already_standard_count).to_f / total_blobs) * 100).round(2) : 0

    puts "\n" + "🎯" * 3 + " RESULTS " + "🎯" * 3
    puts "Success Rate: #{success_rate}% (#{copied_count + already_standard_count}/#{total_blobs})"

    if success_rate >= 95
      puts "\n✅ Excellent! Your images are now set up for hybrid storage:"
      puts "  • Files copied to standard ActiveStorage paths"
      puts "  • Blobs converted to hybrid service"
      puts "  • System will serve from local first, cloud fallback"
      puts "  • You can now safely remove DigitalOcean later"
      puts ""
      puts "Next steps:"
      puts "  1. Test that images still load correctly"
      puts "  2. Monitor for a few days"
      puts "  3. When ready: rails images:convert_all_to_local_only"
    elsif success_rate >= 80
      puts "\n⚠️  Good progress but some issues to resolve"
      puts "  • Most files are now in standard paths"
      puts "  • Missing files will use cloud fallback"
      puts "  • Review the issues above for missing files"
    else
      puts "\n❌ Significant issues found"
      puts "  • Many files couldn't be copied"
      puts "  • Check descriptive file locations"
      puts "  • Consider running: rails images:complete_hybrid_migration"
    end

    puts "\n" + "=" * 70
  end

  desc "Find and list all descriptive files"
  task list_descriptive_files: :environment do
    puts "Descriptive Files Inventory"
    puts "=" * 40

    descriptive_root = Rails.root.join("storage", "descriptive")

    if Dir.exist?(descriptive_root)
      descriptive_files = Dir.glob(descriptive_root.join("**", "*")).select { |f| File.file?(f) }
      total_size = descriptive_files.sum { |f| File.size(f) }

      puts "Descriptive files found: #{descriptive_files.count}"
      puts "Total size: #{human_size(total_size)}"

      # Sample files
      puts "\nSample files:"
      descriptive_files.first(10).each do |file|
        relative_path = Pathname.new(file).relative_path_from(Rails.root)
        size = File.size(file)

        # Try to extract blob key from filename
        basename = File.basename(file, ".*")
        if basename.match(/([a-z0-9]{28})$/)
          blob_key = $1
          blob = ActiveStorage::Blob.find_by(key: blob_key)

          puts "  #{relative_path}"
          puts "    Size: #{human_size(size)}"
          puts "    Blob: #{blob ? "Found (service: #{blob.service_name})" : "Not found"}"
        else
          puts "  #{relative_path} (no blob key found)"
        end
      end

      # Check for blobs without descriptive files
      missing_descriptive = 0
      ActiveStorage::Blob.limit(100).each do |blob|
        descriptive_file = find_descriptive_file_for_blob(blob)
        missing_descriptive += 1 unless descriptive_file && File.exist?(descriptive_file)
      end

      puts "\nSample blobs missing descriptive files: #{missing_descriptive}/100"

    else
      puts "No descriptive directory found at: #{descriptive_root}"
    end
  end

  private

  def find_descriptive_file_for_blob(blob)
    # Look for descriptive files that end with the blob key
    descriptive_root = Rails.root.join("storage", "descriptive")
    return nil unless Dir.exist?(descriptive_root)

    # Pattern: any file ending with the blob key
    pattern = descriptive_root.join("**", "*#{blob.key}.*")
    matches = Dir.glob(pattern)

    # Return the first match, or nil if none found
    matches.first
  end

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
