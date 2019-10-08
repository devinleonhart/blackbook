class CharacterTrait < ApplicationRecord
  validates :character, uniqueness: { scope: :trait_id }

  belongs_to :character, inverse_of: :character_traits
  belongs_to :trait, inverse_of: :character_traits
end
