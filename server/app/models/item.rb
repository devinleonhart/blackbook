# frozen_string_literal: true

class Item < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :character_items, dependent: :restrict_with_error, inverse_of: :item
  has_many :characters, through: :character_items, dependent:
    :restrict_with_error, inverse_of: :items
end
