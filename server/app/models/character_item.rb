class CharacterItem < ApplicationRecord
  validates :character, uniqueness: { scope: :item_id }

  belongs_to :character, inverse_of: :character_items
  belongs_to :item, inverse_of: :character_items
end
