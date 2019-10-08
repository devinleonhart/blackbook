class Trait < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :character_traits, inverse_of: :trait
  has_many :characters, through: :character_traits, inverse_of: :traits
end
