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
# Indexes
#
#  index_items_on_name  (name) UNIQUE
#

class Item < ApplicationRecord
  include PgSearch::Model

  multisearchable against: [:name]

  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :character_items, dependent: :restrict_with_error, inverse_of: :item
  has_many :characters, through: :character_items, dependent:
    :restrict_with_error, inverse_of: :items
end
