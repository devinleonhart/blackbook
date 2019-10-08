class Item < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :character_items, inverse_of: :item
  has_many :characters, through: :character_items, inverse_of: :items
end
