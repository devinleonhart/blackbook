# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require "factory_bot_rails"

puts "🌱 Starting Blackbook database seeding..."

# Only clear data in development environment
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  ImageTag.destroy_all
  Image.destroy_all
  Character.destroy_all
  Collaboration.destroy_all
  Universe.destroy_all
  User.destroy_all
end

ActiveRecord::Base.transaction do
  # Create test users
  puts "👥 Creating users..."
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
  puts "🌌 Creating universes..."
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
  puts "🤝 Creating collaborations..."
  FactoryBot.create(:collaboration, user: creative_user, universe: fantasy_universe)
  FactoryBot.create(:collaboration, user: collaborator_user, universe: collaborative_universe)

  # Create characters
  puts "👤 Creating characters..."
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
  puts "🖼️  Creating images and tags..."
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
    "Mount Doom in the distance"
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
    "Space dock maintenance"
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
    "The pantheon's celestial realm"
  ]

  # Create fantasy images
  fantasy_characters = [aragorn, legolas, gimli, gandalf, frodo]
  fantasy_images = []
  20.times do |i|
    caption = fantasy_captions[i % fantasy_captions.length]
    image = FactoryBot.create(:image_for_seeding, universe: fantasy_universe, caption: caption)
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
    image = FactoryBot.create(:image_for_seeding, universe: scifi_universe, caption: caption)
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
    image = FactoryBot.create(:image_for_seeding, universe: collaborative_universe, caption: caption)
    mythology_images << image

    # Tag with 1-2 random characters
    tagged_characters = mythology_characters.sample(rand(1..2))
    tagged_characters.each do |character|
      FactoryBot.create(:image_tag, image: image, character: character)
    end
  end

  # Create additional images for pagination testing
  puts "📚 Creating additional content for testing..."
  additional_images = []
  30.times do |i|
    universe = [fantasy_universe, scifi_universe, collaborative_universe].sample
    characters = case universe
                 when fantasy_universe then fantasy_characters
                 when scifi_universe then scifi_characters
                 else mythology_characters
                 end

    caption = "Additional content #{i + 1} for #{universe.name}"
    image = FactoryBot.create(:image_for_seeding, universe: universe, caption: caption)
    additional_images << image

    # Tag with 1-2 random characters
    tagged_characters = characters.sample(rand(1..2))
    tagged_characters.each do |character|
      FactoryBot.create(:image_tag, image: image, character: character)
    end
  end

  puts "✅ Seeding completed successfully!"
  puts ""
  puts "📊 Summary:"
  puts "  👥 Users: #{User.count}"
  puts "  🌌 Universes: #{Universe.count}"
  puts "  👤 Characters: #{Character.count}"
  puts "  🖼️  Images: #{Image.count}"
  puts "  🏷️  Image tags: #{ImageTag.count}"
  puts "  🤝 Collaborations: #{Collaboration.count}"
  puts ""
  puts "🔐 Test accounts:"
  puts "  Admin: admin@blackbook.dev / password123"
  puts "  Writer: writer@blackbook.dev / password123"
  puts "  Collaborator: collaborator@blackbook.dev / password123"
end
