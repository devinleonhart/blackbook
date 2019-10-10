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

FactoryBot.define do
  factory :character_item do
    character
    item
  end
end
