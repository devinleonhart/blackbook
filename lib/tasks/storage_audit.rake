# frozen_string_literal: true

namespace :images do
  desc "Audit storage for orphaned blobs and files"
  task storage_audit: :environment do
    puts "Storage Audit Report"
    puts "=" * 60

    storage_root = Rails.root.join("storage")

    # Audit 1: Find orphaned blobs (not attached to any record)
    puts "\n1. ORPHANED BLOBS (in database but not attached to anything)"
    puts "-" * 50

    all_blobs = ActiveStorage::Blob.all
    attached_blob_ids = ActiveStorage::Attachment.distinct.pluck(:blob_id)
    orphaned_blobs = all_blobs.where.not(id: attached_blob_ids)

    puts "Total blobs: #{all_blobs.count}"
    puts "Attached blobs: #{attached_blob_ids.count}"
    puts "Orphaned blobs: #{orphaned_blobs.count}"

    orphaned_size = 0
    orphaned_local_files = 0

    if orphaned_blobs.any?
      puts "\nOrphaned blobs:"
      orphaned_blobs.limit(20).each do |blob|
        local_path = storage_root.join(blob.key[0..1], blob.key[2..3], blob.key)
        has_local = File.exist?(local_path)
        file_size = has_local ? File.size(local_path) : 0

        orphaned_size += blob.byte_size
        orphaned_local_files += 1 if has_local

        puts "  ID #{blob.id}: #{blob.filename} (#{human_size(blob.byte_size)}) " \
             "Local: #{has_local ? '✓' : '✗'} Service: #{blob.service_name}"
      end

      if orphaned_blobs.count > 20
        puts "  ... and #{orphaned_blobs.count - 20} more"

        # Calculate remaining totals
        orphaned_blobs.offset(20).find_each do |blob|
          local_path = storage_root.join(blob.key[0..1], blob.key[2..3], blob.key)
          orphaned_size += blob.byte_size
          orphaned_local_files += 1 if File.exist?(local_path)
        end
      end

      puts "\nOrphaned blob summary:"
      puts "  Total wasted space: #{human_size(orphaned_size)}"
      puts "  Orphaned files with local copies: #{orphaned_local_files}"
    end

    # Audit 2: Find orphaned local files (files without database records)
    puts "\n2. ORPHANED LOCAL FILES (files on disk but not in database)"
    puts "-" * 50

    if Dir.exist?(storage_root)
      all_blob_keys = Set.new(ActiveStorage::Blob.pluck(:key))
      orphaned_files = []
      orphaned_files_size = 0

      # Scan storage directory
      Dir.glob(storage_root.join("*", "*", "*")).each do |file_path|
        next unless File.file?(file_path)

        # Extract key from path (last part)
        key = File.basename(file_path)

        # Skip if this key exists in database
        next if all_blob_keys.include?(key)

        file_size = File.size(file_path)
        orphaned_files << {
          path: file_path,
          key: key,
          size: file_size,
          modified: File.mtime(file_path)
        }
        orphaned_files_size += file_size
      end

      puts "Orphaned local files: #{orphaned_files.count}"
      puts "Total wasted disk space: #{human_size(orphaned_files_size)}"

      if orphaned_files.any?
        puts "\nSample orphaned files:"
        orphaned_files.first(10).each do |file|
          puts "  #{file[:key]} (#{human_size(file[:size])}) - Modified: #{file[:modified].strftime('%Y-%m-%d %H:%M')}"
        end
        puts "  ... and #{orphaned_files.count - 10} more" if orphaned_files.count > 10
      end
    else
      puts "Storage directory doesn't exist: #{storage_root}"
    end

    # Audit 3: Image models without attachments
    puts "\n3. IMAGE MODELS WITHOUT ATTACHMENTS"
    puts "-" * 50

    images_without_files = Image.left_joins(:image_file_attachment)
                                .where(active_storage_attachments: { id: nil })

    puts "Image models without attachments: #{images_without_files.count}"

    if images_without_files.any?
      puts "\nImage models missing file attachments:"
      images_without_files.limit(10).each do |image|
        puts "  Image ID #{image.id} (Universe: #{image.universe.name})"
      end
      puts "  ... and #{images_without_files.count - 10} more" if images_without_files.count > 10
    end

    # Audit 4: Blobs with missing local files (for hybrid/local service)
    puts "\n4. BLOBS MISSING LOCAL FILES"
    puts "-" * 50

    local_service_blobs = ActiveStorage::Blob.where(service_name: ['local', 'local_production', 'hybrid'])
    missing_local_count = 0
    missing_local_size = 0

    local_service_blobs.find_each do |blob|
      local_path = storage_root.join(blob.key[0..1], blob.key[2..3], blob.key)

      unless File.exist?(local_path) && File.size(local_path) == blob.byte_size
        missing_local_count += 1
        missing_local_size += blob.byte_size

        if missing_local_count <= 10
          puts "  #{blob.filename} (#{blob.service_name}) - #{human_size(blob.byte_size)}"
        end
      end
    end

    puts "Blobs missing local files: #{missing_local_count}/#{local_service_blobs.count}"
    puts "Total size of missing files: #{human_size(missing_local_size)}"
    puts "  ... and #{missing_local_count - 10} more" if missing_local_count > 10

    # Summary and recommendations
    puts "\n" + "=" * 60
    puts "SUMMARY & RECOMMENDATIONS"
    puts "=" * 60

    total_waste = orphaned_size + orphaned_files_size
    puts "Total wasted storage: #{human_size(total_waste)}"

    if orphaned_blobs.any?
      puts "\n🧹 Clean up orphaned blobs:"
      puts "  rails images:cleanup_orphaned_blobs"
    end

    if orphaned_files.any?
      puts "\n🧹 Clean up orphaned files:"
      puts "  rails images:cleanup_orphaned_files"
    end

    if missing_local_count > 0
      puts "\n📥 Download missing local files:"
      puts "  rails images:complete_hybrid_migration"
    end

    if images_without_files.any?
      puts "\n🗑️  Clean up broken Image models:"
      puts "  rails images:cleanup_broken_image_models"
    end

    puts "\n✅ Overall storage health: #{storage_health_score(orphaned_blobs.count, orphaned_files.count, missing_local_count, all_blobs.count)}"
  end

  desc "Clean up orphaned blobs from database"
  task cleanup_orphaned_blobs: :environment do
    puts "Cleaning up orphaned blobs..."

    attached_blob_ids = ActiveStorage::Attachment.distinct.pluck(:blob_id)
    orphaned_blobs = ActiveStorage::Blob.where.not(id: attached_blob_ids)

    puts "Found #{orphaned_blobs.count} orphaned blobs"

    if orphaned_blobs.count == 0
      puts "✅ No orphaned blobs to clean up"
      return
    end

    # Show what will be deleted
    total_size = orphaned_blobs.sum(:byte_size)
    puts "Will free up #{human_size(total_size)} from database"

    deleted_count = 0
    orphaned_blobs.find_each do |blob|
      # Also delete the local file if it exists
      local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)
      File.delete(local_path) if File.exist?(local_path)

      blob.destroy
      deleted_count += 1

      puts "  ✓ Deleted blob #{blob.id} (#{blob.filename})" if deleted_count <= 10
    end

    puts "  ... and #{deleted_count - 10} more" if deleted_count > 10
    puts "\n✅ Cleaned up #{deleted_count} orphaned blobs"
  end

  desc "Clean up orphaned files from storage directory"
  task cleanup_orphaned_files: :environment do
    puts "Cleaning up orphaned local files..."

    storage_root = Rails.root.join("storage")
    all_blob_keys = Set.new(ActiveStorage::Blob.pluck(:key))

    deleted_count = 0
    deleted_size = 0

    Dir.glob(storage_root.join("*", "*", "*")).each do |file_path|
      next unless File.file?(file_path)

      key = File.basename(file_path)
      next if all_blob_keys.include?(key)

      file_size = File.size(file_path)
      File.delete(file_path)

      deleted_count += 1
      deleted_size += file_size

      puts "  ✓ Deleted #{key} (#{human_size(file_size)})" if deleted_count <= 10
    end

    puts "  ... and #{deleted_count - 10} more" if deleted_count > 10
    puts "\n✅ Cleaned up #{deleted_count} orphaned files (#{human_size(deleted_size)})"
  end

  desc "Clean up Image models without file attachments"
  task cleanup_broken_image_models: :environment do
    puts "Cleaning up broken Image models..."

    broken_images = Image.left_joins(:image_file_attachment)
                         .where(active_storage_attachments: { id: nil })

    puts "Found #{broken_images.count} Image models without attachments"

    if broken_images.count == 0
      puts "✅ No broken Image models to clean up"
      return
    end

    deleted_count = 0
    broken_images.find_each do |image|
      image.destroy
      deleted_count += 1
      puts "  ✓ Deleted Image #{image.id}" if deleted_count <= 10
    end

    puts "  ... and #{deleted_count - 10} more" if deleted_count > 10
    puts "\n✅ Cleaned up #{deleted_count} broken Image models"
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

  def storage_health_score(orphaned_blobs, orphaned_files, missing_local, total_blobs)
    issues = orphaned_blobs + orphaned_files + missing_local
    return "Excellent (no issues found)" if issues == 0

    issue_ratio = issues.to_f / total_blobs

    case issue_ratio
    when 0..0.05
      "Good (minor cleanup needed)"
    when 0.05..0.15
      "Fair (some cleanup recommended)"
    when 0.15..0.30
      "Poor (significant cleanup needed)"
    else
      "Critical (major storage issues)"
    end
  end
end
