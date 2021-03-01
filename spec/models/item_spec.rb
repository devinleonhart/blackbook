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

require "rails_helper"

RSpec.describe Item, type: :model do
  it "is valid with valid attributes" do
    @item = build(:item, name: "Max's Sword");
    expect(@item).to be_valid
  end

  it "is invalid when name is missing" do
    @item = build(:item, name: nil);
    expect(@item).to be_invalid
  end

  it "is invalid when name is already taken" do
    @item1 = create(:item, name: "Max's Sword");
    @item2 = build(:item, name: "Max's Sword");
    expect(@item1).to be_valid
    expect(@item2).to be_invalid
  end
end
