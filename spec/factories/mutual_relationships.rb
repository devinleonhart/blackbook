# frozen_string_literal: true

# == Schema Information
#
# Table name: mutual_relationships
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  sequence(:relationship_name) { |n| "Relationship #{n}" }

  factory :mutual_relationship do
    transient do
      character_universe { create(:universe) }
      character1 { create(:character, universe: character_universe) }
      character2 { create(:character, universe: character_universe) }
      forward_name { generate(:relationship_name) }
      reverse_name { generate(:relationship_name) }
    end

    after(:build) do |mutual_relationship, evaluator|
      create(
        :relationship,
        originating_character: evaluator.character1,
        target_character: evaluator.character2,
        name: evaluator.forward_name,
        mutual_relationship: mutual_relationship,
      )
      create(
        :relationship,
        originating_character: evaluator.character2,
        target_character: evaluator.character1,
        name: evaluator.reverse_name,
        mutual_relationship: mutual_relationship,
      )
    end
  end
end
