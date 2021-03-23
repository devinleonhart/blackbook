# frozen_string_literal: true

# == Schema Information
#
# Table name: character_traits
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#  trait_id     :bigint           not null
#
# Indexes
#
#  index_character_traits_on_character_id               (character_id)
#  index_character_traits_on_character_id_and_trait_id  (character_id,trait_id) UNIQUE
#  index_character_traits_on_trait_id                   (trait_id)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
#  fk_rails_...  (trait_id => traits.id)
#

require "rails_helper"

RSpec.describe CharacterTrait, type: :model do

  before do
    @character = FactoryBot.create(:character)
    @trait = FactoryBot.create(:trait)
  end

  it "should create a valid character_trait" do
    @character_trait = build(:character_trait, character: @character, trait: @trait)
    expect(@character_trait).to be_valid
  end

  it "should create be invalid when character is missing" do
    @character_trait = build(:character_trait, character: nil, trait: @trait)
    expect(@character_trait).to be_invalid
  end

  it "should create be invalid when trait is missing" do
    @character_trait = build(:character_trait, character: @character, trait: nil)
    expect(@character_trait).to be_invalid
  end

  it "should not allow a duplicate trait" do
    @character_trait1 = create(:character_trait, character: @character, trait: @trait)
    @character_trait2 = build(:character_trait, character: @character, trait: @trait)
    expect(@character_trait1).to be_valid
    expect(@character_trait2).to be_invalid
  end
end
