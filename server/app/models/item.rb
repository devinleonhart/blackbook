# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Item < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  has_many :character_items, dependent: :restrict_with_error, inverse_of: :item
  has_many :characters, through: :character_items, dependent:
    :restrict_with_error, inverse_of: :items
end
