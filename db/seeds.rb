# frozen_string_literal: true

# Enhanced seed file to comprehensively test all models and relationships in Blackbook
require "factory_bot_rails"

puts "Starting Blackbook database seeding..."

ActiveRecord::Base.transaction do
  # Clear existing data in development
  if Rails.env.development?
    puts "Clearing existing data..."
    ImageTag.destroy_all
    Image.destroy_all
    Relationship.destroy_all
    MutualRelationship.destroy_all
    Character.destroy_all
    Collaboration.destroy_all
    Universe.destroy_all
    User.destroy_all
  end

  puts "Creating users..."
  # Create test users
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

  puts "Creating universes..."
  # Create main fantasy universe with rich content
  fantasy_universe = FactoryBot.create(
    :universe,
    name: "The Realm of Aethermoor",
    owner: admin_user
  )

  # Create sci-fi universe
  scifi_universe = FactoryBot.create(
    :universe,
    name: "Galactic Federation",
    owner: creative_user
  )

  # Create collaborative universe
  collaborative_universe = FactoryBot.create(
    :universe,
    name: "Shared Mythology",
    owner: creative_user
  )

  puts "Creating collaborations..."
  # Add collaborations
  FactoryBot.create(:collaboration, user: collaborator_user, universe: fantasy_universe)
  FactoryBot.create(:collaboration, user: admin_user, universe: collaborative_universe)

  puts "Creating characters..."
  # Fantasy universe characters
  aragorn = FactoryBot.create(:character, name: "Aragorn the Ranger", universe: fantasy_universe)
  legolas = FactoryBot.create(:character, name: "Legolas Greenleaf", universe: fantasy_universe)
  gimli = FactoryBot.create(:character, name: "Gimli the Dwarf", universe: fantasy_universe)
  gandalf = FactoryBot.create(:character, name: "Gandalf the Grey", universe: fantasy_universe)
  frodo = FactoryBot.create(:character, name: "Frodo Baggins", universe: fantasy_universe)

  # Sci-fi universe characters
  captain_kirk = FactoryBot.create(:character, name: "Captain James T. Kirk", universe: scifi_universe)
  spock = FactoryBot.create(:character, name: "Mr. Spock", universe: scifi_universe)
  mccoy = FactoryBot.create(:character, name: "Dr. Leonard McCoy", universe: scifi_universe)

  # Collaborative universe characters
  zeus = FactoryBot.create(:character, name: "Zeus", universe: collaborative_universe)
  athena = FactoryBot.create(:character, name: "Athena", universe: collaborative_universe)

  puts "Creating relationships..."
  # Create complex relationships in fantasy universe
  fellowship_bond = FactoryBot.create(
    :mutual_relationship,
    character1: aragorn,
    character2: legolas,
    relationship1_name: "trusted friend",
    relationship2_name: "loyal companion"
  )

  dwarf_elf_friendship = FactoryBot.create(
    :mutual_relationship,
    character1: legolas,
    character2: gimli,
    relationship1_name: "unlikely friend",
    relationship2_name: "respected ally"
  )

  mentor_student = FactoryBot.create(
    :mutual_relationship,
    character1: gandalf,
    character2: frodo,
    relationship1_name: "wise mentor",
    relationship2_name: "faithful student"
  )

  # Sci-fi relationships
  command_team = FactoryBot.create(
    :mutual_relationship,
    character1: captain_kirk,
    character2: spock,
    relationship1_name: "commanding officer",
    relationship2_name: "first officer"
  )

  # Family relationship in mythology
  family_bond = FactoryBot.create(
    :mutual_relationship,
    character1: zeus,
    character2: athena,
    relationship1_name: "father",
    relationship2_name: "daughter"
  )

  puts "Creating images..."
  # Create sample images for characters
  fantasy_image1 = FactoryBot.create(
    :image,
    universe: fantasy_universe,
    caption: "The Fellowship of the Ring gathered at Rivendell",
    favorite: true
  )

  fantasy_image2 = FactoryBot.create(
    :image,
    universe: fantasy_universe,
    caption: "Gandalf casting a spell in Moria"
  )

  scifi_image1 = FactoryBot.create(
    :image,
    universe: scifi_universe,
    caption: "Bridge crew of the USS Enterprise",
    favorite: true
  )

  puts "Creating image tags..."
  # Tag characters in images
  FactoryBot.create(:image_tag, character: aragorn, image: fantasy_image1)
  FactoryBot.create(:image_tag, character: legolas, image: fantasy_image1)
  FactoryBot.create(:image_tag, character: gimli, image: fantasy_image1)
  FactoryBot.create(:image_tag, character: frodo, image: fantasy_image1)

  FactoryBot.create(:image_tag, character: gandalf, image: fantasy_image2)

  FactoryBot.create(:image_tag, character: captain_kirk, image: scifi_image1)
  FactoryBot.create(:image_tag, character: spock, image: scifi_image1)
  FactoryBot.create(:image_tag, character: mccoy, image: scifi_image1)

  puts "Seeding completed successfully!"
  puts "Summary:"
  puts "- Users created: #{User.count}"
  puts "- Universes created: #{Universe.count}"
  puts "- Characters created: #{Character.count}"
  puts "- Relationships created: #{Relationship.count}"
  puts "- Mutual relationships created: #{MutualRelationship.count}"
  puts "- Images created: #{Image.count}"
  puts "- Image tags created: #{ImageTag.count}"
  puts "- Collaborations created: #{Collaboration.count}"

  puts "\nTest users for login:"
  puts "Admin: admin@blackbook.dev / password123"
  puts "Writer: writer@blackbook.dev / password123"
  puts "Collaborator: collaborator@blackbook.dev / password123"
end
