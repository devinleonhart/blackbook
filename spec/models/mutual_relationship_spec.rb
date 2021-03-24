# frozen_string_literal: true

# == Schema Information
#
# Table name: mutual_relationships
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe MutualRelationship, type: :model do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @universe1 = FactoryBot.create(:universe, { owner: @user1, name: "Seraph" })
    @universe2 = FactoryBot.create(:universe, { owner: @user1, name: "Knighthood" })
    @universe3 = FactoryBot.create(:universe, { owner: @user2 })
    @character1 = FactoryBot.create(:character, { name: "Max Lionheart", universe: @universe1 })
    @character2 = FactoryBot.create(:character, { name: "Lise Awen", universe: @universe1 })
    @character3 = FactoryBot.create(:character, { name: "Gina Sabatier", universe: @universe2 })
    @character4 = FactoryBot.create(:character, { name: "Dahlia Morgan", universe: @universe3 })
  end

  it "should allow a relationship between characters in the same universe." do
    @relationship1 = FactoryBot.build(:relationship,
      { name: "Boyfriend", originating_character: @character1, target_character: @character2,
        mutual_relationship: @mutual_relationship, })
    @relationship2 = FactoryBot.build(:relationship,
      { name: "Girlfriend", originating_character: @character2, target_character: @character1,
        mutual_relationship: @mutual_relationship, })
    @mutual_relationship = FactoryBot.build(:mutual_relationship, { relationships: [@relationship1, @relationship2] })
    expect(@mutual_relationship).to be_valid
  end

  it "should list the universe of the related characters." do
    @relationship1 = FactoryBot.build(:relationship,
      { name: "Boyfriend", originating_character: @character1, target_character: @character2,
        mutual_relationship: @mutual_relationship, })
    @relationship2 = FactoryBot.build(:relationship,
      { name: "Girlfriend", originating_character: @character2, target_character: @character1,
        mutual_relationship: @mutual_relationship, })
    @mutual_relationship = FactoryBot.build(:mutual_relationship, { relationships: [@relationship1, @relationship2] })
    expect(@mutual_relationship.universe).to eq(@character1.universe)
  end

  it "should list the characters in the relationship." do
    @relationship1 = FactoryBot.build(:relationship,
      { name: "Boyfriend", originating_character: @character1, target_character: @character2,
        mutual_relationship: @mutual_relationship, })
    @relationship2 = FactoryBot.build(:relationship,
      { name: "Girlfriend", originating_character: @character2, target_character: @character1,
        mutual_relationship: @mutual_relationship, })
    @mutual_relationship = FactoryBot.build(:mutual_relationship, { relationships: [@relationship1, @relationship2] })
    expect(@mutual_relationship.characters.any? { |character| character.name == "Max Lionheart" }).to equal(true)
    expect(@mutual_relationship.characters.any? { |character| character.name == "Lise Awen" }).to equal(true)
    expect(@mutual_relationship.characters.count).to equal(2)
  end

  it "should not allow a relationship between characters in different universes." do
    @relationship1 = FactoryBot.build(:relationship,
      { name: "Friend", originating_character: @character3, target_character: @character4,
        mutual_relationship: @mutual_relationship, })
    @relationship2 = FactoryBot.build(:relationship,
      { name: "Friend", originating_character: @character4, target_character: @character3,
        mutual_relationship: @mutual_relationship, })
    @mutual_relationship = FactoryBot.build(:mutual_relationship, { relationships: [@relationship1, @relationship2] })
    expect(@mutual_relationship).to be_invalid
  end
end
