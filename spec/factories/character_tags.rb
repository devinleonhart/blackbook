# == Schema Information
#
# Table name: character_tags
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#
# Indexes
#
#  index_character_tags_on_character_id_and_name  (character_id,name) UNIQUE
#  index_character_tags_on_name                   (name)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
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

