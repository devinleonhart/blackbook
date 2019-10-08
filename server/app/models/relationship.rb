# frozen_string_literal: true

class Relationship < ApplicationRecord
  validates :name, presence: true
  validates(
    :name,
    uniqueness: {
      scope: %i[originating_character_id target_character_id],
      case_sensitive: false,
    }
  )

  belongs_to :originating_character, class_name: 'Character', inverse_of:
    :originating_relationships
  belongs_to :target_character, class_name: 'Character', inverse_of:
    :target_relationships
  belongs_to :mutual_relationship, inverse_of: :relationships
end
