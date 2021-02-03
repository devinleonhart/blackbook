# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
require "factory_bot_rails"

ActiveRecord::Base.transaction do
  # Users
  user1 = FactoryBot.build(
    :user,
    display_name: "user1",
    email: "user1@lionheart.design",
    encrypted_password: "password1",
  )
  user1.save!

  user2 = FactoryBot.build(
    :user,
    display_name: "user2",
    email: "user2@lionheart.design",
    encrypted_password: "password2",
  )
  user2.save!

  # Universes
  universe1 = FactoryBot.create(
    :universe,
    name: "universe1",
    owner: user1
  )

  # Characters
  FactoryBot.create(
    :character,
    universe: universe1,
    name: "Character 1",
    description: "Character 1's Description",
  )
end
# rubocop:enable Metrics/BlockLength
