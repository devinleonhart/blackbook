# frozen_string_literal: true

# == Schema Information
#
# Table name: character_items
#
#  id           :bigint           not null, primary key
#  character_id :bigint           not null
#  item_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CharacterItem < ApplicationRecord
  validates :character, uniqueness: { scope: :item_id }

  belongs_to :character, inverse_of: :character_items
  belongs_to :item, inverse_of: :character_items

  delegate :universe, to: :character, allow_nil: true
end
