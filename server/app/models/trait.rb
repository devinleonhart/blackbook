# frozen_string_literal: true

class Trait < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  has_many :character_traits, dependent: :restrict_with_error, inverse_of:
    :trait
  has_many :characters, through: :character_traits, dependent:
    :restrict_with_error, inverse_of: :traits
end
