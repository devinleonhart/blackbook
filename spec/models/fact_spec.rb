# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fact, type: :model do
  it "is valid with valid attached models" do
    @character = create(:character, name: "Max")
    @character_fact = create(:fact, character_id: @character.id)
    expect(@character_fact).to be_valid
    expect(@character_fact.character.name).to eq("Max")
  end

  it "is valid without attached models" do
    @character_fact = create(:fact)
    expect(@character_fact).to be_valid
  end

  it "is valid when bound to two different models" do
    @character = create(:character, name: "Max")
    @location = create(:location, name: "Nomad")
    @fact = create(:fact, character_id: @character.id, location_id: @location.id)
    expect(@fact).to be_valid
    expect(@fact.character.name).to eq("Max")
    expect(@fact.location.name).to eq("Nomad")
  end

  it "is invalid when fact_type is nil or blank" do
    @character = create(:character, name: "Max")
    @character_fact = build(:fact, fact_type: nil, character_id: @character.id)
    expect(@character_fact).to be_invalid
    @character_fact = build(:fact, fact_type: "", character_id: @character.id)
    expect(@character_fact).to be_invalid
  end

  it "is invalid when content is nil or blank" do
    @character = create(:character, name: "Max")
    @character_fact = build(:fact, content: nil, character_id: @character.id)
    expect(@character_fact).to be_invalid
    @character_fact = build(:fact, content: "", character_id: @character.id)
    expect(@character_fact).to be_invalid
  end
end
