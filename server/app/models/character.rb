# frozen_string_literal: true

class Character < ApplicationRecord
  include Discard::Model

  validates :name, :description, presence: true
  validates :name, uniqueness: { scope: :universe_id, case_sensitive: false }

  belongs_to :universe, inverse_of: :characters

  has_many :character_traits, inverse_of: :character, dependent: :destroy
  has_many :traits, through: :character_traits, inverse_of: :characters

  has_many :character_items, inverse_of: :character, dependent: :destroy
  has_many :items, through: :character_items, inverse_of: :characters

  has_many :originating_relationships, class_name: "Relationship", foreign_key:
    :originating_character_id, dependent: :destroy, inverse_of:
    :originating_character
  has_many :target_relationships, class_name: "Relationship", foreign_key:
    :target_character_id, dependent: :destroy, inverse_of: :target_character

  def relationships
    originating_relationships + target_relationships
  end
end
