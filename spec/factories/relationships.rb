# frozen_string_literal: true

# == Schema Information
#
# Table name: relationships
#
#  id                       :bigint           not null, primary key
#  name                     :citext           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  mutual_relationship_id   :bigint           not null
#  originating_character_id :bigint           not null
#  target_character_id      :bigint           not null
#
# Indexes
#
#  index_relationships_on_mutual_relationship_id    (mutual_relationship_id)
#  index_relationships_on_originating_character_id  (originating_character_id)
#  index_relationships_on_target_character_id       (target_character_id)
#  relationships_unique_constraint                  (originating_character_id,target_character_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (originating_character_id => characters.id)
#  fk_rails_...  (target_character_id => characters.id)
#

FactoryBot.define do
  # NOTE: the Relationship factory doesn't work on its own, it cannot be used
  # directly. You have to use the MutualRelationships factory to create
  # Relationships.
  factory :relationship do
    transient do
      character_universe { create(:universe) }
    end

    mutual_relationship
    association :originating_character, factory: :character
    association :target_character, factory: :character

    after(:build) do |relationship, evaluator|
      next if relationship.originating_character.nil?
      next if relationship.target_character.nil?

      universe = evaluator.character_universe
      relationship.originating_character.universe = universe
      relationship.target_character.universe = universe
    end
  end
end
