# frozen_string_literal: true

# == Schema Information
#
# Table name: relationships
#
#  id                       :bigint           not null, primary key
#  name                     :citext           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  mutual_relationship_id   :integer          not null
#  originating_character_id :integer          not null
#  target_character_id      :integer          not null
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

class Relationship < ApplicationRecord
  validates :name, presence: true
  validates(
    :name,
    uniqueness: {
      scope: [:originating_character_id, :target_character_id],
      case_sensitive: false,
    }
  )
  validate :characters_must_be_in_same_universe, :no_self_relationships

  belongs_to :originating_character, class_name: "Character", inverse_of:
    :originating_relationships
  belongs_to :target_character, class_name: "Character", inverse_of:
    :target_relationships
  belongs_to :mutual_relationship, inverse_of: :relationships

  delegate :universe, to: :originating_character, allow_nil: true

  private

  def characters_must_be_in_same_universe
    return if originating_character.nil? || target_character.nil?

    if originating_character.universe != target_character.universe
      errors.add(:base, "all characters must belong to the same universe")
    end
  end

  def no_self_relationships
    return if originating_character.nil? || target_character.nil?

    errors.add(:base, "A character can't have a relationship with itself.") if originating_character == target_character
  end
end
