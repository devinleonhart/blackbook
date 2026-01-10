# frozen_string_literal: true

FactoryBot.define do
  factory :character_tag do
    character
    sequence(:name) { |n| "tag#{n}" }

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
