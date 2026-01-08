# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImageTag, type: :model do
  subject(:image_tag) { build(:image_tag) }

  describe "associations" do
    it { is_expected.to belong_to(:character).inverse_of(:image_tags) }
    it { is_expected.to belong_to(:image).inverse_of(:image_tags) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:character).scoped_to(:image_id) }

    it "requires the character and image to be from the same universe" do
      character = create(:character)
      other_universe = create(:universe)
      image = create(:image, universe: other_universe)

      invalid_tag = described_class.new(character: character, image: image)
      expect(invalid_tag).not_to be_valid
      expect(invalid_tag.errors[:base]).to be_present
    end
  end

  describe "#universe" do
    it "delegates to character" do
      character = create(:character)
      image = create(:image, universe: character.universe)

      tag = create(:image_tag, character: character, image: image)
      expect(tag.universe).to eq(character.universe)
    end
  end
end
