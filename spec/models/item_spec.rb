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

require "rails_helper"

RSpec.describe Item, type: :model do
  before do
    @item1 = FactoryBot.create(:item, { name: "Max's Sword" })
  end

  it "should not allow an empty item name" do
    @item1.name = ""
    expect(@item1).to be_invalid
  end

  it "should not allow a nil item name" do
    @item1.name = nil
    expect(@item1).to be_invalid
  end

  it "should not allow a duplicate item name" do
    @item2 = FactoryBot.build(:item, { name: "Max's Sword" })
    expect(@item2).to be_invalid
  end
end
