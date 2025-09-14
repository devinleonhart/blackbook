# frozen_string_literal: true

namespace :images do
  desc "Revert all Active Storage blobs to use digitalocean service"
  task revert_to_digitalocean: :environment do
    puts "Reverting Active Storage blobs to use digitalocean service..."

    # Find all blobs that are not using the digitalocean service
    blobs_to_update = ActiveStorage::Blob.where.not(service_name: 'digitalocean')

    puts "Found #{blobs_to_update.count} blobs to revert"

    if blobs_to_update.count == 0
      puts "No blobs need reverting!"
      return
    end

    updated_count = 0

    blobs_to_update.find_each do |blob|
      begin
        old_service = blob.service_name
        blob.update!(service_name: 'digitalocean')
        puts "  ✓ Reverted blob #{blob.id} from '#{old_service}' to 'digitalocean'"
        updated_count += 1
      rescue => e
        puts "  ✗ Failed to revert blob #{blob.id}: #{e.message}"
      end
    end

    puts "\nCompleted!"
    puts "Reverted #{updated_count} blobs to use digitalocean service"
    puts "All images should now use cloud storage"
  end
end
