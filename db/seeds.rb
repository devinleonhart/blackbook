# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require "factory_bot_rails"

def create_characters(number_of_characters)
  FactoryBot.create_list(:character, number_of_characters) do |character|
    character.traits = FactoryBot.create_list(:trait, 50)
    character.items = FactoryBot.create_list(:item, 10)
  end
end

def create_locations(number_of_locations)
  FactoryBot.create_list(:location, number_of_locations)
end

def relate_characters(characters)
  characters.each_with_index do |character, index|
    if index.zero?
      FactoryBot.create(:mutual_relationship, character_universe: character.universe, character1: character,
                                              character2: characters[characters.length - 1])
    else
      FactoryBot.create(:mutual_relationship, character_universe: character.universe, character1: character,
                                              character2: characters[index - 1])
    end
  end
end

ActiveRecord::Base.transaction do
  # Users
  user1 = FactoryBot.build(
    :user,
    display_name: "user1",
    email: "user1@lionheart.design",
    password: "password1",
  )
  user1.save!

  user2 = FactoryBot.build(
    :user,
    display_name: "user2",
    email: "user2@lionheart.design",
    password: "password2",
  )
  user2.save!

  # Universes
  universe1 = FactoryBot.build(
    :universe,
    name: "universe1",
    owner: user1,
    collaborators: [user2],
    characters: create_characters(5),
    locations: create_locations(5)
  )

  relate_characters(universe1.characters)

  universe2 = FactoryBot.build(
    :universe,
    name: "universe2",
    owner: user1,
    collaborators: [user2],
    characters: create_characters(5),
    locations: create_locations(5)
  )

  universe3 = FactoryBot.build(
    :universe,
    name: "universe3",
    characters: create_characters(5),
    owner: user1
  )

  universe4 = FactoryBot.build(
    :universe,
    name: "universe4",
    characters: create_characters(5),
    owner: user2
  )

  universe1.save!
  universe2.save!
  universe3.save!
  universe4.save!
end
# rubocop:enable Metrics/BlockLength
