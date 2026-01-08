# frozen_string_literal: true

# == Schema Information
#
# Table name: character_tags
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  character_id :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :character_tag do
    character
    name { Faker::Lorem.word.downcase }

    trait :human do
      name { "human" }
    end

    trait :elf do
      name { "elf" }
    end

    trait :warrior do
      name { "warrior" }
    end

    trait :mage do
      name { "mage" }
    end

    trait :noble do
      name { "noble" }
    end
  end
end
