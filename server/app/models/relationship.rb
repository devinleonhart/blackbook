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

class Relationship < ApplicationRecord
  include PgSearch::Model

  multisearchable against: [:name]

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

  def characters_must_be_in_same_universe
    return if originating_character.nil? || target_character.nil?

    if originating_character.universe != target_character.universe
      errors.add(:base, "all characters must belong to the same universe")
    end
  end

  def no_self_relationships
    return if originating_character.nil? || target_character.nil?

    if originating_character == target_character
      errors.add(:base, "A character can't have a relationship with itself.")
    end
  end
end
