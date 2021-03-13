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

require "rails_helper"

RSpec.describe CharacterItem, type: :model do
  it "is valid with valid attached models" do
    @character = create(:character, name: "Max")
    @item = create(:item, name: "Max's Sword")
    @character_item = build(:character_item, character: @character, item: @item)
    expect(@character_item).to be_valid
  end

  it "is invalid with missing character" do
    @item = create(:item, name: "Max's Sword")
    @character_item = build(:character_item, character: nil, item: @item)
    expect(@character_item).to be_invalid
  end

  it "is invalid with missing item" do
    @character = create(:character, name: "Max")
    @character_item = build(:character_item, character: @character, item: @item)
    expect(@character_item).to be_invalid
  end

  it "is invalid when attacking the same models twice" do
    @character = create(:character, name: "Max")
    @item = create(:item, name: "Max's Sword")
    @character_item1 = create(:character_item, character: @character,
                                               item: @item)
    @character_item2 = build(:character_item, character: @character,
                                              item: @item)
    expect(@character_item1).to be_valid
    expect(@character_item2).to be_invalid
  end
end
