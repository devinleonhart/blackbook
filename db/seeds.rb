# frozen_string_literal: true

require "stringio"
require "securerandom"

def seed_image_bytes
  path = Rails.root.join("spec/fixtures/files/test_image.jpg")
  return nil unless File.exist?(path)

  File.binread(path)
end

def seed_image_variants(bytes, count: 6)
  return [] if bytes.nil?

  (0...count).map do |i|
    bytes + "\nSEED_VARIANT=#{i}\n"
  end
end

def attach_seed_image!(image, bytes, filename: "seed_image.jpg")
  return if bytes.nil?

  image.image_file.attach(
    io: StringIO.new(bytes),
    filename: filename,
    content_type: "image/jpeg"
  )
end

def create_user!(email:, display_name:, admin: false, password: "password123")
  User.create!(
    email: email,
    display_name: display_name,
    password: password,
    password_confirmation: password,
    admin: admin
  )
end

def seed_sample_data!
  rng = Random.new(42)

  base_bytes = seed_image_bytes
  image_variants = seed_image_variants(base_bytes, count: 8)

  admin = create_user!(email: "admin@blackbook.dev", display_name: "Admin", admin: true)
  owner = create_user!(email: "owner@blackbook.dev", display_name: "Owner")
  collaborator = create_user!(email: "collaborator@blackbook.dev", display_name: "Collaborator")
  alice = create_user!(email: "alice@blackbook.dev", display_name: "Alice")
  bob = create_user!(email: "bob@blackbook.dev", display_name: "Bob")

  users = [admin, owner, collaborator, alice, bob]

  # --- Universes (mix of ownership + collaborations) ---
  universe_specs = [
    { name: "Example Universe", owner: owner, collaborators: [collaborator, alice] },
    { name: "Cyber City", owner: owner, collaborators: [bob] },
    { name: "High Fantasy", owner: alice, collaborators: [owner, collaborator] },
    { name: "Space Opera", owner: bob, collaborators: [owner] },
    { name: "Admin Universe", owner: admin, collaborators: [] }
  ]

  universes =
    universe_specs.map do |spec|
      u = Universe.create!(name: spec[:name], owner: spec[:owner])
      Array(spec[:collaborators]).each { |c| Collaboration.create!(universe: u, user: c) }
      u
    end

  # --- Characters + character tags ---
  tag_pool = %w[
    hero villain sidekick mentor rival antihero
    mage warrior rogue cleric ranger
    android hacker detective noble
    leader outlaw scholar spy
    protagonist antagonist
    fire ice lightning shadow light
    ally enemy neutral
    healer tank dps
    royal commoner merchant
  ]

  character_name_pool = [
    "Astra", "Nova", "Ember", "Sable", "Orion", "Lyra", "Iris", "Vega", "Juno", "Echo",
    "Rook", "Cipher", "Nyx", "Sol", "Zephyr", "Rowan", "Mira", "Kai", "Riven", "Arden",
    "Morrigan", "Thorne", "Alaric", "Seraph", "Briar", "Cassia", "Vale", "Juniper"
  ]

  characters_by_universe = {}
  universes.each_with_index do |universe, idx|
    count = universe.name == "Admin Universe" ? 6 : (12 + (idx * 4))
    names = character_name_pool.sample(count, random: rng)

    characters = names.map { |name| Character.create!(universe: universe, name: name) }
    characters_by_universe[universe.id] = characters

    characters.each do |character|
      # Give each character a couple tags, with some overlap for the tag browser.
      tags = tag_pool.sample(2 + rng.rand(3), random: rng)
      tags.each { |t| character.character_tags.create!(name: t) }
    end
  end

  # --- Images + image tags ---
  caption_bits = [
    "portrait", "action shot", "group scene", "concept art", "reference", "location study",
    "dramatic lighting", "alternate costume", "battle", "quiet moment", "flashback"
  ]

  images_by_universe = {}
  universes.each do |universe|
    image_count =
      case universe.name
      when "Example Universe" then 180
      when "Cyber City" then 80
      when "High Fantasy", "Space Opera" then 80
      when "Admin Universe" then 180
      else 50
      end

    images = []
    image_count.times do |i|
      caption = "#{universe.name} — #{caption_bits.sample(random: rng)} ##{format('%02d', i + 1)}"
      image = Image.new(universe: universe, caption: caption)

      if image_variants.any?
        bytes = image_variants.sample(random: rng)
        attach_seed_image!(image, bytes, filename: "seed_#{universe.id}_#{i}.jpg")
      end

      image.save!
      images << image
    end

    images_by_universe[universe.id] = images

    universe_characters = characters_by_universe.fetch(universe.id)

    images.each_with_index do |image, i|
      # Ensure some untagged images for the "untagged" filter.
      next if (i % 5).zero?

      tag_count = 1 + rng.rand(3) # 1..3 characters tagged per image
      universe_characters.sample(tag_count, random: rng).each do |character|
        ImageTag.find_or_create_by!(image: image, character: character)
      end
    end
  end

  # --- Favorites ---
  users.each do |user|
    visible_universes = user.owned_universes + user.contributor_universes
    visible_images = visible_universes.flat_map(&:images)

    # Favorite ~15% of visible images, capped for sanity.
    target = [(visible_images.size * 0.15).round, 25].min
    visible_images.sample(target, random: rng).each do |image|
      ImageFavorite.find_or_create_by!(user: user, image: image)
    end
  end
end

def clear_dev_data!
  ImageFavorite.delete_all
  ImageTag.delete_all
  CharacterTag.delete_all
  Image.delete_all
  Character.delete_all
  Collaboration.delete_all
  Universe.delete_all
  User.delete_all

  ActiveStorage::Attachment.delete_all
  ActiveStorage::VariantRecord.delete_all
  ActiveStorage::Blob.delete_all
end

return unless Rails.env.development?

Rails.logger.info "Seeding development data..."

ActiveRecord::Base.transaction do
  clear_dev_data!
  seed_sample_data!
end

Rails.logger.info "Seed complete."
Rails.logger.info "Accounts:"
Rails.logger.info "  Admin: admin@blackbook.dev / password123"
Rails.logger.info "  Owner: owner@blackbook.dev / password123"
Rails.logger.info "  Collaborator: collaborator@blackbook.dev / password123"
Rails.logger.info "  Alice: alice@blackbook.dev / password123"
Rails.logger.info "  Bob: bob@blackbook.dev / password123"
