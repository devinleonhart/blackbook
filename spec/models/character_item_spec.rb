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
  before do
    @character = FactoryBot.create(:character)
    @item = FactoryBot.create(:item)
  end

  it "should create a valid character_item" do
    @character_item = build(:character_item, character: @character, item: @item)
    expect(@character_item).to be_valid
  end

  it "should create be invalid when character is missing" do
    @character_item = build(:character_item, character: nil, item: @item)
    expect(@character_item).to be_invalid
  end

  it "should create be invalid when item is missing" do
    @character_item = build(:character_item, character: @character, item: nil)
    expect(@character_item).to be_invalid
  end

  it "should not allow a duplicate item" do
    @character_item1 = create(:character_item, character: @character, item: @item)
    @character_item2 = build(:character_item, character: @character, item: @item)
    expect(@character_item1).to be_valid
    expect(@character_item2).to be_invalid
  end
end
