# frozen_string_literal: true

# == Schema Information
#
# Table name: relationships
#
#  id                       :bigint           not null, primary key
#  mutual_relationship_id   :bigint           not null
#  originating_character_id :bigint           not null
#  target_character_id      :bigint           not null
#  name                     :citext           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require "rails_helper"

RSpec.describe Relationship, type: :model do
  let(:universe) { create :universe }

  describe "validations" do
    subject do
      Relationship.new(
        originating_character: create(:character),
        target_character: create(:character),
        name: "rel",
        mutual_relationship: MutualRelationship.create!,
      )
    end

    it { should validate_presence_of(:name) }

    describe "characters_must_be_in_same_universe" do
      context "when the characters are unset" do
        let(:relationship) do
          Relationship.new(
            name: "rel",
            mutual_relationship: MutualRelationship.create!,
          )
        end

        it "shouldn't raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to be_empty
        end
      end

      context "when the originating_character is unset" do
        let(:relationship) do
          mutual_relationship = MutualRelationship.create!
          Relationship.new(
            target_character: create(:character),
            name: "rel",
            mutual_relationship: mutual_relationship
          )
        end

        it "shouldn't raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to be_empty
        end
      end

      context "when the target character is unset" do
        let(:relationship) do
          Relationship.new(
            originating_character: create(:character),
            name: "rel",
            mutual_relationship: MutualRelationship.create!,
          )
        end

        it "shouldn't raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to be_empty
        end
      end

      context "when the originating character and target character belong to the same universe" do
        let(:relationship) do
          Relationship.new(
            originating_character: create(:character, universe: universe),
            target_character: create(:character, universe: universe),
            name: "rel",
            mutual_relationship: MutualRelationship.create!,
          )
        end

        it "shouldn't raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to be_empty
        end
      end

      context "when the originating character and target character belong to different universes" do
        let(:relationship) do
          Relationship.new(
            originating_character: create(:character),
            target_character: create(:character),
            name: "rel",
            mutual_relationship: MutualRelationship.create!,
          )
        end

        it "should raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to(
            eq(["all characters must belong to the same universe"])
          )
        end
      end
    end

    describe "no_self_relationships" do
      context "when the characters are unset" do
        let(:relationship) do
          Relationship.new(
            name: "rel",
            mutual_relationship: MutualRelationship.create!,
          )
        end

        it "shouldn't raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to be_empty
        end
      end

      context "when the originating_character is unset" do
        let(:relationship) do
          mutual_relationship = MutualRelationship.create!
          Relationship.new(
            target_character: create(:character),
            name: "rel",
            mutual_relationship: mutual_relationship
          )
        end

        it "shouldn't raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to be_empty
        end
      end

      context "when the target character is unset" do
        let(:relationship) do
          Relationship.new(
            originating_character: create(:character),
            name: "rel",
            mutual_relationship: MutualRelationship.create!,
          )
        end

        it "shouldn't raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to be_empty
        end
      end

      context "when the originating character and target character are different" do
        let(:relationship) do
          Relationship.new(
            originating_character: create(:character, universe: universe),
            target_character: create(:character, universe: universe),
            name: "rel",
            mutual_relationship: MutualRelationship.create!,
          )
        end

        it "shouldn't raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to be_empty
        end
      end

      context "when the originating character and target character are the same character" do
        let(:character) { create :character }

        let(:relationship) do
          Relationship.new(
            originating_character: character,
            target_character: character,
            name: "rel",
            mutual_relationship: MutualRelationship.create!,
          )
        end

        it "should raise an error" do
          relationship.valid?
          expect(relationship.errors[:base]).to(
            eq(["A character can't have a relationship with itself."])
          )
        end
      end
    end

    describe "for uniqueness" do
      subject do
        Relationship.create!(
          originating_character: create(:character, universe: universe),
          target_character: create(:character, universe: universe),
          name: "rel",
          mutual_relationship: MutualRelationship.create!,
        )
      end

      it {
        should(
          validate_uniqueness_of(:name)
          .scoped_to([:originating_character_id, :target_character_id])
          .ignoring_case_sensitivity
        )
      }
    end
  end

  it {
    should(
      belong_to(:mutual_relationship)
      .required
      .inverse_of(:relationships)
    )
  }

  it {
    should(
      belong_to(:originating_character)
      .required
      .class_name("Character")
      .inverse_of(:originating_relationships)
    )
  }

  it {
    should(
      belong_to(:target_character)
      .required
      .class_name("Character")
      .inverse_of(:target_relationships)
    )
  }

  it { should delegate_method(:universe).to(:originating_character).allow_nil }
end
