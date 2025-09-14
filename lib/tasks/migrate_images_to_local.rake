# frozen_string_literal: true

namespace :images do
  desc "Migrate all cloud images to local storage with descriptive filenames"
  task migrate_to_local: :environment do
    puts "Starting image migration from cloud to local storage with descriptive filenames..."

    # Ensure local storage directories exist
    local_storage_path = Rails.root.join("storage")
    descriptive_storage_path = Rails.root.join("storage", "descriptive")
    FileUtils.mkdir_p(local_storage_path)
    FileUtils.mkdir_p(descriptive_storage_path)

    # Track migration progress
    total_images = Image.joins(:image_file_attachment).includes(:universe, :characters).count
    migrated_count = 0
    failed_count = 0
    failed_images = []

    puts "Found #{total_images} images to migrate"
    puts "Images will be saved with descriptive filenames like: universe_character1_character2_uuid.ext"

    Image.includes({ image_file_attachment: :blob }, :universe, :characters).find_each(batch_size: 10) do |image|
      begin
        next unless image.image_file.attached?

        blob = image.image_file.blob
        descriptive_filename = image.get_or_generate_local_filename

        if descriptive_filename.nil?
          puts "  ⚠ Could not generate filename for image #{image.id}, skipping"
          failed_count += 1
          next
        end

        # Check if descriptive filename already exists
        if image.image_available_locally?
          puts "  ✓ Image #{image.id} already exists locally (#{descriptive_filename})"
          migrated_count += 1
          next
        end

        # Download from cloud and save with descriptive filename
        characters_info = image.characters.any? ? image.characters.pluck(:name).join(", ") : "untagged"
        puts "  → Downloading image #{image.id}: #{image.universe.name} - #{characters_info}"
        puts "    Filename: #{descriptive_filename}"

        # Use the image's built-in method for descriptive download
        if image.download_to_local_with_descriptive_name!
          puts "  ✓ Successfully migrated image #{image.id}"
          migrated_count += 1
        else
          raise "Failed to download with descriptive name"
        end

        # Small delay to avoid overwhelming the system
        sleep(0.1)

      rescue => e
        puts "  ✗ Failed to migrate image #{image.id}: #{e.message}"
        failed_count += 1
        failed_images << {
          id: image.id,
          filename: blob&.filename,
          descriptive_filename: descriptive_filename,
          error: e.message
        }
      end

      # Progress update every 25 images (smaller batches for more feedback)
      if (migrated_count + failed_count) % 25 == 0
        puts "Progress: #{migrated_count + failed_count}/#{total_images} processed"
      end
    end

    puts "\n" + "="*60
    puts "Migration Summary:"
    puts "  Total images: #{total_images}"
    puts "  Successfully migrated: #{migrated_count}"
    puts "  Failed: #{failed_count}"
    puts "  Success rate: #{((migrated_count.to_f / total_images) * 100).round(2)}%"

    if failed_images.any?
      puts "\nFailed images:"
      failed_images.each do |failed|
        puts "  - ID: #{failed[:id]}"
        puts "    Original: #{failed[:filename]}"
        puts "    Descriptive: #{failed[:descriptive_filename]}"
        puts "    Error: #{failed[:error]}"
        puts ""
      end
    end

    puts "="*60
  end

  desc "Verify local image files exist and match cloud versions"
  task verify_migration: :environment do
    puts "Verifying migrated images..."

    verified_count = 0
    missing_count = 0
    size_mismatch_count = 0

    Image.includes(image_file_attachment: :blob).find_each do |image|
      next unless image.image_file.attached?

      blob = image.image_file.blob
      local_path = local_file_path(blob.key)

      if !File.exist?(local_path)
        puts "  ✗ Missing local file for image #{image.id}: #{blob.filename}"
        missing_count += 1
      elsif File.size(local_path) != blob.byte_size
        puts "  ✗ Size mismatch for image #{image.id}: #{blob.filename} (local: #{File.size(local_path)}, cloud: #{blob.byte_size})"
        size_mismatch_count += 1
      else
        verified_count += 1
      end
    end

    puts "\nVerification Summary:"
    puts "  Verified: #{verified_count}"
    puts "  Missing: #{missing_count}"
    puts "  Size mismatches: #{size_mismatch_count}"
  end

  desc "Show examples of descriptive filenames that will be generated"
  task preview_filenames: :environment do
    puts "Preview of Descriptive Filenames"
    puts "=" * 40

    sample_size = [20, Image.count].min
    puts "Showing #{sample_size} examples:\n\n"

    Image.includes(:universe, :characters, { image_file_attachment: :blob })
         .limit(sample_size)
         .each do |image|
      next unless image.image_file.attached?

      descriptive_filename = image.get_or_generate_local_filename
      original_filename = image.image_file.blob.filename.to_s
      characters_list = image.characters.pluck(:name).join(", ").presence || "No characters"

      puts "Image ID: #{image.id}"
      puts "  Universe: #{image.universe.name}"
      puts "  Characters: #{characters_list}"
      puts "  Original: #{original_filename}"
      puts "  Descriptive: #{descriptive_filename}"
      puts ""
    end

    puts "Note: Filenames are sanitized (lowercase, special chars become underscores)"
    puts "Format: <universe>_<character1>_<character2>_<uuid>.<extension>"
  end

  desc "Clean up failed or incomplete local image files"
  task cleanup_failed: :environment do
    puts "Cleaning up failed local image files..."

    cleaned_count = 0

    Image.includes(image_file_attachment: :blob).find_each do |image|
      next unless image.image_file.attached?

      blob = image.image_file.blob

      # Check both original and descriptive paths
      original_path = local_file_path(blob.key)
      descriptive_path = image.local_file_path

      [original_path, descriptive_path].compact.each do |path|
        if File.exist?(path) && File.size(path) != blob.byte_size
          puts "  → Removing corrupted file: #{File.basename(path)}"
          File.delete(path)
          cleaned_count += 1
        end
      end
    end

    puts "Cleaned up #{cleaned_count} corrupted files"
  end

  private

  def local_file_path(key)
    # Match Active Storage's local disk service path structure
    Rails.root.join("storage", key[0..1], key[2..3], key)
  end
end
