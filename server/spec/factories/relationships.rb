# frozen_string_literal: true

# == Schema Information
#
# Table name: relationships
#
#  id                       :bigint           not null, primary key
#  mutual_relationship_id   :bigint           not null
#  originating_character_id :bigint           not null
#  target_character_id      :bigint           not null
#  name                     :citext           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

FactoryBot.define do
  factory :relationship do
    transient do
      character_universe { create(:universe) }
    end

    mutual_relationship
    association :originating_character, factory: :character
    association :target_character, factory: :character
    sequence(:name) { |n| "Relationship #{n}" }

    after(:build) do |relationship, evaluator|
      next if relationship.originating_character.nil?
      next if relationship.target_character.nil?

      universe = evaluator.character_universe
      relationship.originating_character.universe = universe
      relationship.target_character.universe = universe
    end
  end
end
