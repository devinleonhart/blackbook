# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "factory_bot_rails"
require "stringio"

Rails.logger.debug "🌱 Starting Blackbook database seeding..."

# Only clear data in development environment
if Rails.env.development?
  Rails.logger.debug "🧹 Clearing existing data..."
  ImageFavorite.destroy_all
  ImageTag.destroy_all
  Image.destroy_all
  Character.destroy_all
  Collaboration.destroy_all
  Universe.destroy_all
  User.destroy_all
end

ActiveRecord::Base.transaction do
  seed_image_path = Rails.root.join("spec/fixtures/files/test_image.jpg")
  seed_image_bytes =
    if File.exist?(seed_image_path)
      File.binread(seed_image_path)
    else
      Rails.logger.debug { "⚠️  Seed image not found at #{seed_image_path}; images will not have attachments." }
      nil
    end

  # Create test users
  Rails.logger.debug "👥 Creating users..."
  admin_user = FactoryBot.create(
    :user,
    admin: true,
    display_name: "Admin User",
    email: "admin@blackbook.dev",
    password: "password123"
  )

  creative_user = FactoryBot.create(
    :user,
    admin: false,
    display_name: "Creative Writer",
    email: "writer@blackbook.dev",
    password: "password123"
  )

  collaborator_user = FactoryBot.create(
    :user,
    admin: false,
    display_name: "Collaborator",
    email: "collaborator@blackbook.dev",
    password: "password123"
  )

  # Create universes
  Rails.logger.debug "🌌 Creating universes..."
  fantasy_universe = FactoryBot.create(
    :universe,
    name: "The Realm of Aethermoor",
    owner: admin_user
  )

  scifi_universe = FactoryBot.create(
    :universe,
    name: "Nexus Station Alpha",
    owner: creative_user
  )

  collaborative_universe = FactoryBot.create(
    :universe,
    name: "Mythological Pantheon",
    owner: admin_user
  )

  # Create collaborations
  Rails.logger.debug "🤝 Creating collaborations..."
  FactoryBot.create(:collaboration, user: creative_user, universe: fantasy_universe)
  FactoryBot.create(:collaboration, user: collaborator_user, universe: collaborative_universe)

  # Create characters
  Rails.logger.debug "👤 Creating characters..."
  # Fantasy universe characters
  aragorn = FactoryBot.create(:character, name: "Aragorn", universe: fantasy_universe)
  legolas = FactoryBot.create(:character, name: "Legolas", universe: fantasy_universe)
  gimli = FactoryBot.create(:character, name: "Gimli", universe: fantasy_universe)
  gandalf = FactoryBot.create(:character, name: "Gandalf", universe: fantasy_universe)
  frodo = FactoryBot.create(:character, name: "Frodo", universe: fantasy_universe)

  # Sci-fi universe characters
  captain_kirk = FactoryBot.create(:character, name: "Captain Kirk", universe: scifi_universe)
  spock = FactoryBot.create(:character, name: "Spock", universe: scifi_universe)

  # Collaborative universe characters
  zeus = FactoryBot.create(:character, name: "Zeus", universe: collaborative_universe)
  athena = FactoryBot.create(:character, name: "Athena", universe: collaborative_universe)

  # Create images with tags
  Rails.logger.debug "🖼️  Creating images and tags..."
  fantasy_captions = [
    "The Fellowship of the Ring gathered at Rivendell",
    "Aragorn wielding Andúril, the Flame of the West",
    "Legolas demonstrating his archery skills",
    "Gimli with his mighty axe",
    "Gandalf the Grey in his study",
    "Frodo carrying the One Ring",
    "The Mines of Moria entrance",
    "Rivendell's beautiful architecture",
    "The Shire's peaceful countryside",
    "Mount Doom in the distance",
  ]

  scifi_captions = [
    "USS Enterprise in deep space",
    "Captain Kirk on the bridge",
    "Spock performing a Vulcan salute",
    "The transporter room",
    "Engineering section of the ship",
    "Away team on an alien planet",
    "The ship's mess hall",
    "Captain's quarters",
    "The ship's library",
    "Space dock maintenance",
  ]

  mythology_captions = [
    "Zeus wielding his thunderbolt",
    "Athena with her owl companion",
    "Mount Olympus in all its glory",
    "The Parthenon temple",
    "Greek gods in council",
    "Athena's wisdom and warfare",
    "Zeus's throne room",
    "The gods' banquet hall",
    "Athena's sacred olive tree",
    "The pantheon's celestial realm",
  ]

  # Create fantasy images
  fantasy_characters = [aragorn, legolas, gimli, gandalf, frodo]
  fantasy_images = []
  20.times do |i|
    caption = fantasy_captions[i % fantasy_captions.length]
    image = Image.new(universe: fantasy_universe, caption: caption)
    if seed_image_bytes
      image.image_file.attach(
        io: StringIO.new(seed_image_bytes),
        filename: "seed_image.jpg",
        content_type: "image/jpeg",
      )
    end
    image.save!
    fantasy_images << image

    # Tag with 1-3 random characters
    tagged_characters = fantasy_characters.sample(rand(1..3))
    tagged_characters.each do |character|
      FactoryBot.create(:image_tag, image: image, character: character)
    end
  end

  # Create sci-fi images
  scifi_characters = [captain_kirk, spock]
  scifi_images = []
  20.times do |i|
    caption = scifi_captions[i % scifi_captions.length]
    image = Image.new(universe: scifi_universe, caption: caption)
    if seed_image_bytes
      image.image_file.attach(
        io: StringIO.new(seed_image_bytes),
        filename: "seed_image.jpg",
        content_type: "image/jpeg",
      )
    end
    image.save!
    scifi_images << image

    # Tag with 1-2 random characters
    tagged_characters = scifi_characters.sample(rand(1..2))
    tagged_characters.each do |character|
      FactoryBot.create(:image_tag, image: image, character: character)
    end
  end

  # Create mythology images
  mythology_characters = [zeus, athena]
  mythology_images = []
  20.times do |i|
    caption = mythology_captions[i % mythology_captions.length]
    image = Image.new(universe: collaborative_universe, caption: caption)
    if seed_image_bytes
      image.image_file.attach(
        io: StringIO.new(seed_image_bytes),
        filename: "seed_image.jpg",
        content_type: "image/jpeg",
      )
    end
    image.save!
    mythology_images << image

    # Tag with 1-2 random characters
    tagged_characters = mythology_characters.sample(rand(1..2))
    tagged_characters.each do |character|
      FactoryBot.create(:image_tag, image: image, character: character)
    end
  end

  # Create additional images for pagination testing
  Rails.logger.debug "📚 Creating additional content for testing..."
  additional_images = []
  30.times do |i|
    universe = [fantasy_universe, scifi_universe, collaborative_universe].sample
    characters = case universe
    when fantasy_universe then fantasy_characters
    when scifi_universe then scifi_characters
    else mythology_characters
    end

    caption = "Additional content #{i + 1} for #{universe.name}"
    image = Image.new(universe: universe, caption: caption)
    if seed_image_bytes
      image.image_file.attach(
        io: StringIO.new(seed_image_bytes),
        filename: "seed_image.jpg",
        content_type: "image/jpeg",
      )
    end
    image.save!
    additional_images << image

    # Tag with 1-2 random characters
    tagged_characters = characters.sample(rand(1..2))
    tagged_characters.each do |character|
      FactoryBot.create(:image_tag, image: image, character: character)
    end
  end

  # Create some per-user favorites to demonstrate the feature
  Rails.logger.debug "⭐ Creating per-user favorites..."
  fantasy_images.sample(5).each { |img| ImageFavorite.find_or_create_by!(user: admin_user, image: img) }
  # collaborator on fantasy_universe
  fantasy_images.sample(3).each do |img|
    ImageFavorite.find_or_create_by!(user: creative_user, image: img)
  end
  scifi_images.sample(5).each { |img| ImageFavorite.find_or_create_by!(user: creative_user, image: img) }
  mythology_images.sample(4).each do |img|
    ImageFavorite.find_or_create_by!(user: admin_user, image: img)
    ImageFavorite.find_or_create_by!(user: collaborator_user, image: img)
  end

  Rails.logger.debug "✅ Seeding completed successfully!"
  Rails.logger.debug ""
  Rails.logger.debug "📊 Summary:"
  Rails.logger.debug { "  👥 Users: #{User.count}" }
  Rails.logger.debug { "  🌌 Universes: #{Universe.count}" }
  Rails.logger.debug { "  👤 Characters: #{Character.count}" }
  Rails.logger.debug { "  🖼️  Images: #{Image.count}" }
  Rails.logger.debug { "  🏷️  Image tags: #{ImageTag.count}" }
  Rails.logger.debug { "  ⭐ Image favorites: #{ImageFavorite.count}" }
  Rails.logger.debug { "  🤝 Collaborations: #{Collaboration.count}" }
  Rails.logger.debug ""
  Rails.logger.debug "🔐 Test accounts:"
  Rails.logger.debug "  Admin: admin@blackbook.dev / password123"
  Rails.logger.debug "  Writer: writer@blackbook.dev / password123"
  Rails.logger.debug "  Collaborator: collaborator@blackbook.dev / password123"
end
