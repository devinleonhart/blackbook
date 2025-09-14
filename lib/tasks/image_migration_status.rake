# frozen_string_literal: true

namespace :images do
  desc "Check the status of image migration to local storage"
  task migration_status: :environment do
    puts "Image Migration Status Report"
    puts "=" * 50

    total_images = Image.joins(:image_file_attachment).count
    puts "Total images: #{total_images}"

    if total_images == 0
      puts "No images found in the system."
      next
    end

    local_available = 0
    cloud_available = 0
    both_available = 0
    neither_available = 0
    error_count = 0

    Image.includes(image_file_attachment: :blob).find_each(batch_size: 50) do |image|
      begin
        status = image.storage_status

        if status[:local] && status[:cloud]
          both_available += 1
        elsif status[:local]
          local_available += 1
        elsif status[:cloud]
          cloud_available += 1
        else
          neither_available += 1
        end
      rescue => e
        error_count += 1
        puts "Error checking image #{image.id}: #{e.message}"
      end
    end

    puts "\nStorage Distribution:"
    puts "  Both local & cloud: #{both_available} (#{percentage(both_available, total_images)}%)"
    puts "  Local only: #{local_available} (#{percentage(local_available, total_images)}%)"
    puts "  Cloud only: #{cloud_available} (#{percentage(cloud_available, total_images)}%)"
    puts "  Neither available: #{neither_available} (#{percentage(neither_available, total_images)}%)"
    puts "  Errors: #{error_count}" if error_count > 0

    migration_progress = percentage(local_available + both_available, total_images)
    puts "\nMigration Progress: #{migration_progress}% of images available locally"

    if cloud_available > 0
      puts "\n⚠️  #{cloud_available} images are only available in cloud storage"
      puts "   Run 'rails images:migrate_to_local' to download them"
    end

    if neither_available > 0
      puts "\n❌ #{neither_available} images are not available in either storage"
      puts "   These may need manual investigation"
    end

    if both_available == total_images
      puts "\n✅ Migration complete! All images are available in both storages"
      puts "   You can now switch to local-only storage if desired"
    end
  end

  desc "List images that are missing from local storage"
  task missing_local: :environment do
    puts "Images Missing from Local Storage:"
    puts "=" * 40

    missing_count = 0

    Image.includes(image_file_attachment: :blob).find_each do |image|
      next if image.image_available_locally?

      missing_count += 1
      blob = image.image_file.blob
      puts "ID: #{image.id}, File: #{blob.filename}, Size: #{blob.byte_size} bytes, Key: #{blob.key}"
    end

    if missing_count == 0
      puts "✅ All images are available locally!"
    else
      puts "\nTotal missing: #{missing_count}"
      puts "Run 'rails images:migrate_to_local' to download them"
    end
  end

  desc "Show storage usage statistics"
  task storage_stats: :environment do
    puts "Storage Usage Statistics"
    puts "=" * 30

    total_size = 0
    local_size = 0
    file_count = 0

    Image.includes(image_file_attachment: :blob).find_each do |image|
      next unless image.image_file.attached?

      blob = image.image_file.blob
      file_size = blob.byte_size
      total_size += file_size
      file_count += 1

      if image.image_available_locally?
        local_size += file_size
      end
    end

    puts "Total files: #{file_count}"
    puts "Total size: #{human_size(total_size)}"
    puts "Local size: #{human_size(local_size)} (#{percentage(local_size, total_size)}%)"
    puts "Cloud size: #{human_size(total_size)} (estimated, includes all files)"

    if local_size < total_size
      remaining = total_size - local_size
      puts "Remaining to download: #{human_size(remaining)}"
    end
  end

  desc "Fix images that failed to upload to both storages"
  task fix_failed_uploads: :environment do
    puts "Fixing images that failed to upload to both storages..."

    fixed_count = 0
    failed_count = 0

    Image.includes(image_file_attachment: :blob).find_each do |image|
      status = image.storage_status

      # Skip if available in both or neither
      next if (status[:local] && status[:cloud]) || (!status[:local] && !status[:cloud])

      puts "Fixing image #{image.id} (#{image.image_file.blob.filename})"

      if image.resync_to_both_storages!
        fixed_count += 1
        puts "  ✅ Fixed"
      else
        failed_count += 1
        puts "  ❌ Failed to fix"
      end
    end

    puts "\nResults:"
    puts "  Fixed: #{fixed_count}"
    puts "  Failed: #{failed_count}"
  end

  private

  def percentage(part, total)
    return 0 if total == 0
    ((part.to_f / total) * 100).round(1)
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
