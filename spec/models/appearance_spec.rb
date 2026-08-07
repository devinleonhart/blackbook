# frozen_string_literal: true

# == Schema Information
#
# Table name: appearances
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#  image_id     :bigint           not null
#
# Indexes
#
#  index_appearances_on_character_id               (character_id)
#  index_appearances_on_character_id_and_image_id  (character_id,image_id) UNIQUE
#  index_appearances_on_image_id                   (image_id)
#
require "rails_helper"

RSpec.describe Appearance, type: :model do
  subject(:appearance) { build(:appearance) }

  describe "associations" do
    it { is_expected.to belong_to(:character).inverse_of(:appearances) }
    it { is_expected.to belong_to(:image).inverse_of(:appearances) }
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

      tag = create(:appearance, character: character, image: image)
      expect(tag.universe).to eq(character.universe)
    end
  end
end
