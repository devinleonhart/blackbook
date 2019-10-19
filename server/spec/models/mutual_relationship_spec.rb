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
  it {
    should(
      have_many(:relationships)
      .inverse_of(:mutual_relationship)
      .dependent(:destroy)
    )
  }

  describe ".characters" do
    context "when the relationships are unset" do
      subject(:mutual_relationship) do
        MutualRelationship.new
      end

      it "returns an empty array" do
        expect(mutual_relationship.characters).to eq([])
      end
    end

    context "when one relationship is set" do
      let(:universe) { create :universe }
      let(:character1) { build :character, universe: universe }
      let(:character2) { build :character, universe: universe }

      subject(:mutual_relationship) do
        mutual_relationship = MutualRelationship.new
        mutual_relationship.relationships << Relationship.new(
          originating_character: character1,
          target_character: character2,
        )
        mutual_relationship
      end

      it "returns an array with both characters in the relationship" do
        expect(mutual_relationship.characters).to match_array([
          character1,
          character2,
        ])
      end
    end

    context "when both relationships are set" do
      let(:universe) { create :universe }
      let(:character1) { build :character, universe: universe }
      let(:character2) { build :character, universe: universe }

      subject(:mutual_relationship) do
        build(
          :mutual_relationship,
          character1: character1,
          character2: character2,
          character_universe: universe,
        )
      end

      it "returns an array with both characters in the relationship" do
        expect(mutual_relationship.characters).to match_array([
          character1,
          character2,
        ])
      end
    end
  end
end
