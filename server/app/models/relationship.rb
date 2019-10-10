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
  validates :name, presence: true
  validates(
    :name,
    uniqueness: {
      scope: [:originating_character_id, :target_character_id],
      case_sensitive: false,
    }
  )

  belongs_to :originating_character, class_name: "Character", inverse_of:
    :originating_relationships
  belongs_to :target_character, class_name: "Character", inverse_of:
    :target_relationships
  belongs_to :mutual_relationship, inverse_of: :relationships
end
