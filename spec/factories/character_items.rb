# frozen_string_literal: true

# == Schema Information
#
# Table name: character_items
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#  item_id      :bigint           not null
#
# Indexes
#
#  index_character_items_on_character_id              (character_id)
#  index_character_items_on_character_id_and_item_id  (character_id,item_id) UNIQUE
#  index_character_items_on_item_id                   (item_id)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
#  fk_rails_...  (item_id => items.id)
#

FactoryBot.define do
  factory :character_item do
    character
    item
  end
end
