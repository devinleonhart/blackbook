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

  it "is valid with valid relationships" do
    @max = create(:character, name: "Max")
    @lise = create(:character, name: "Lise")
    @mutual_relationship = build(:mutual_relationship, character1: @max, character2: @lise, forward_name: "Boyfriend", reverse_name: "Girlfriend");
    expect(@mutual_relationship).to be_valid
  end

  it "raises error when characters are related to themselves" do
    @max = create(:character, name: "Max")
    expect { build(:mutual_relationship, character1: @max, character2: @max, forward_name: "Uhh...", reverse_name: "Well...") }.to raise_error("Validation failed: A character can't have a relationship with itself.")
  end

  it "raises error when related characters are not part of the same universe" do
    @universe1 = create(:universe, name: "Universe1")
    @universe2 = create(:universe, name: "Universe2")
    @max = create(:character, name: "Max", universe: @universe1)
    @apollo = create(:character, name: "Apollo", universe: @universe2)
    @mutual_relationship = build(:mutual_relationship, character1: @max, character2: @apollo, forward_name: "Uhh...", reverse_name: "Well...");
    expect(@mutual_relationship).to be_valid
  end

end
