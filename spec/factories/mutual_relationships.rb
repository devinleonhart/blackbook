# == Schema Information
#
# Table name: mutual_relationships
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :mutual_relationship do
    # Create a mutual relationship with two characters and their relationships
    transient do
      character_universe { nil }
      character1 { nil }
      character2 { nil }
      relationship1_name { "friend" }
      relationship2_name { "friend" }
    end

    after(:create) do |mutual_relationship, evaluator|
      # Use provided characters if they exist, otherwise create new ones
      if evaluator.character1 && evaluator.character2
        char1 = evaluator.character1
        char2 = evaluator.character2
        # Make sure they're in the same universe
        char2.update!(universe: char1.universe) if char1.universe != char2.universe
      else
        universe = evaluator.character_universe || create(:universe)
        char1 = evaluator.character1 || create(:character, universe: universe)
        char2 = evaluator.character2 || create(:character, universe: universe)
      end

      # Create the two relationships that make up the mutual relationship
      create(:relationship,
        mutual_relationship: mutual_relationship,
        originating_character: char1,
        target_character: char2,
        name: evaluator.relationship1_name
      )

      create(:relationship,
        mutual_relationship: mutual_relationship,
        originating_character: char2,
        target_character: char1,
        name: evaluator.relationship2_name
      )
    end
  end
end
