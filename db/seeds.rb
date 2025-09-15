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
  # Create 300 images for extensive pagination testing (15 pages with 20 images per page)
  fantasy_images = []
  fantasy_captions = [
    "The Fellowship of the Ring gathered at Rivendell",
    "Gandalf casting a spell in Moria",
    "Aragorn leading the charge at Helm's Deep",
    "Legolas shooting arrows at the Battle of Helm's Deep",
    "Gimli counting his kills",
    "Frodo and Sam in Mordor",
    "The Shire at sunset",
    "Rivendell's waterfalls",
    "The Mines of Moria entrance",
    "Lothlórien's golden trees",
    "The White City of Minas Tirith",
    "Mount Doom in the distance",
    "The Black Gate of Mordor",
    "Rohan's golden plains",
    "Isengard's tower",
    "The Argonath statues",
    "Bilbo's birthday party",
    "The Prancing Pony inn",
    "Weathertop ruins",
    "The Council of Elrond",
    "The Bridge of Khazad-dûm",
    "Gollum in the caves",
    "The Dead Marshes",
    "Osgiliath ruins",
    "The Pelennor Fields",
    "The Paths of the Dead",
    "The Hornburg fortress",
    "The Glittering Caves",
    "The Last Homely House",
    "The Lonely Mountain",
    "The Ring of Power",
    "Sauron's Eye",
    "The One Ring",
    "Bilbo's eleventy-first birthday",
    "The Green Dragon Inn",
    "Bag End's round door",
    "The Old Forest",
    "Tom Bombadil's house",
    "The Barrow-downs",
    "Bree's main street",
    "The Prancing Pony's common room",
    "Strider in the shadows",
    "The Nazgûl on horseback",
    "The Ford of Bruinen",
    "Elrond's healing hands",
    "The Last Homely House",
    "The Misty Mountains",
    "The Caradhras pass",
    "The Watcher in the Water",
    "The Balrog of Moria",
    "Gandalf's fall",
    "The Great Eagles",
    "Lothlórien's mallorn trees",
    "Galadriel's mirror",
    "The gift of the phial",
    "The Anduin River",
    "The Argonath",
    "The Falls of Rauros",
    "Amon Hen",
    "The Breaking of the Fellowship",
    "Boromir's last stand",
    "Merry and Pippin captured",
    "Aragorn's tracking",
    "The Riders of Rohan",
    "The Golden Hall",
    "King Théoden",
    "Éowyn's sword practice",
    "The Hornburg",
    "The Battle of Helm's Deep",
    "The Ents march to Isengard",
    "Treebeard's council",
    "Saruman's tower",
    "The Palantír",
    "Gandalf the White",
    "The Paths of the Dead",
    "The Army of the Dead",
    "The Corsairs of Umbar",
    "The Battle of the Pelennor Fields",
    "Éowyn slays the Witch-king",
    "The Siege of Minas Tirith",
    "The White Tree",
    "The Steward's throne",
    "The Houses of Healing",
    "The Last Debate",
    "The Black Gate",
    "The Mouth of Sauron",
    "The Battle of the Black Gate",
    "The Eagles arrive",
    "The Ring is destroyed",
    "Mount Doom erupts",
    "The Return of the King",
    "The Grey Havens",
    "Sam's garden",
    "The Red Book of Westmarch"
  ]

  # Create 200 fantasy images
  200.times do |i|
    caption = fantasy_captions[i % fantasy_captions.length]
    fantasy_images << FactoryBot.create(
      :image,
      universe: fantasy_universe,
      caption: "#{caption} (#{i + 1})",
      favorite: i < 20 # Make first 20 images favorites
    )
  end

  # Create 60 sci-fi images
  scifi_captions = [
    "Bridge crew of the USS Enterprise",
    "Spock performing a mind meld",
    "Captain Kirk in command",
    "The Enterprise in space",
    "Dr. McCoy with his medical tricorder",
    "The transporter room",
    "Engineering section",
    "The holodeck in action",
    "A Klingon battle cruiser",
    "The planet Vulcan",
    "The Neutral Zone",
    "The Romulan Warbird",
    "The Borg Cube",
    "Data's positronic brain",
    "Geordi's VISOR",
    "Worf's bat'leth",
    "The Defiant",
    "Deep Space Nine",
    "The Dominion War",
    "The Cardassians",
    "The Ferengi",
    "The Bajorans",
    "The Prophets",
    "The Gamma Quadrant",
    "The Alpha Quadrant",
    "The Delta Quadrant",
    "The Q Continuum",
    "The Borg Queen",
    "Seven of Nine",
    "The Voyager",
    "The Delta Flyer",
    "The Maquis",
    "The Temporal Cold War",
    "The Xindi",
    "The Suliban",
    "The Andorians",
    "The Tellarites",
    "The Denobulans",
    "The Vulcan High Command",
    "The Klingon High Council",
    "The Romulan Senate",
    "The Federation Council",
    "Starfleet Academy",
    "The Prime Directive",
    "The Temporal Prime Directive",
    "The Omega Directive",
    "The Genesis Device",
    "The Genesis Planet",
    "The Mutara Nebula",
    "The Klingon Bird of Prey",
    "The Romulan D'deridex",
    "The Borg Sphere",
    "The V'ger Probe",
    "The Whale Probe",
    "The Doomsday Machine",
    "The Planet Killer",
    "The M-5 Computer",
    "The Nomad Probe",
    "The V'ger Entity",
    "The Whale Song",
    "The Genesis Wave",
    "The Genesis Effect"
  ]

  scifi_images = []
  60.times do |i|
    caption = scifi_captions[i % scifi_captions.length]
    scifi_images << FactoryBot.create(
      :image,
      universe: scifi_universe,
      caption: "#{caption} (#{i + 1})",
      favorite: i < 10 # Make first 10 images favorites
    )
  end

  # Create 40 mythology images
  mythology_captions = [
    "Zeus on Mount Olympus",
    "Athena with her owl",
    "The Parthenon in Athens",
    "Poseidon rising from the sea",
    "Apollo with his lyre",
    "Artemis hunting in the forest",
    "Hermes with his winged sandals",
    "Hades in the underworld",
    "The Oracle of Delphi",
    "The Trojan War",
    "The Iliad",
    "The Odyssey",
    "The Aeneid",
    "The Labors of Heracles",
    "The Twelve Olympians",
    "The Titans",
    "The Gigantes",
    "The Cyclopes",
    "The Centaurs",
    "The Satyrs",
    "The Nymphs",
    "The Muses",
    "The Fates",
    "The Furies",
    "The Gorgons",
    "The Sirens",
    "The Minotaur",
    "The Labyrinth",
    "The Golden Fleece",
    "The Argonauts",
    "Jason and the Argonauts",
    "Theseus and the Minotaur",
    "Perseus and Medusa",
    "Bellerophon and Pegasus",
    "Orpheus and Eurydice",
    "Narcissus and Echo",
    "Cupid and Psyche",
    "Dionysus and the Maenads",
    "Demeter and Persephone",
    "Hestia's eternal flame",
    "The Underworld",
    "The River Styx",
    "Charon's boat",
    "Cerberus the three-headed dog",
    "The Elysian Fields",
    "The Asphodel Meadows",
    "Tartarus",
    "The Fates' thread",
    "The Moirai",
    "The Erinyes",
    "The Harpies",
    "The Sphinx",
    "The Chimera",
    "The Hydra",
    "The Nemean Lion",
    "The Erymanthian Boar",
    "The Stymphalian Birds",
    "The Cretan Bull",
    "The Mares of Diomedes",
    "The Belt of Hippolyta",
    "The Cattle of Geryon",
    "The Apples of the Hesperides",
    "The Capture of Cerberus"
  ]

  mythology_images = []
  40.times do |i|
    caption = mythology_captions[i % mythology_captions.length]
    mythology_images << FactoryBot.create(
      :image,
      universe: collaborative_universe,
      caption: "#{caption} (#{i + 1})",
      favorite: i < 5 # Make first 5 images favorites
    )
  end

  puts "Creating image tags..."
  # Tag characters in fantasy images (distribute characters across images)
  fantasy_characters = [aragorn, legolas, gimli, gandalf, frodo]
  fantasy_images.each_with_index do |image, index|
    # Tag each image with 1-3 random characters
    characters_to_tag = fantasy_characters.sample(rand(1..3))
    characters_to_tag.each do |character|
      FactoryBot.create(:image_tag, character: character, image: image)
    end
  end

  # Tag characters in sci-fi images
  scifi_characters = [captain_kirk, spock, mccoy]
  scifi_images.each_with_index do |image, index|
    characters_to_tag = scifi_characters.sample(rand(1..3))
    characters_to_tag.each do |character|
      FactoryBot.create(:image_tag, character: character, image: image)
    end
  end

  # Tag characters in mythology images
  mythology_characters = [zeus, athena]
  mythology_images.each_with_index do |image, index|
    characters_to_tag = mythology_characters.sample(rand(1..2))
    characters_to_tag.each do |character|
      FactoryBot.create(:image_tag, character: character, image: image)
    end
  end

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
