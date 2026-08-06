# frozen_string_literal: true

# == Schema Information
#
# Table name: character_tags
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#
# Indexes
#
#  index_character_tags_on_character_id           (character_id)
#  index_character_tags_on_character_id_and_name  (character_id,name) UNIQUE
#  index_character_tags_on_name                   (name)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
#
require "rails_helper"

RSpec.describe CharacterTag, type: :model do
  subject(:tag) { build(:character_tag, character: character) }

  let(:character) { create(:character) }

  describe "associations" do
    it { is_expected.to belong_to(:character).inverse_of(:character_tags) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "normalizes name to lowercase and strips whitespace" do
      tag.name = "  Elf  "
      tag.validate
      expect(tag.name).to eq("elf")
    end

    it "enforces case-insensitive uniqueness scoped to character" do
      create(:character_tag, character: character, name: "mage")
      dupe = build(:character_tag, character: character, name: "MAGE")
      expect(dupe).not_to be_valid
      expect(dupe.errors[:name]).to be_present
    end
  end

  describe ".characters_with_tag" do
    it "returns characters that have the given tag name" do
      character = create(:character)
      create(:character_tag, character: character, name: "hero")
      create(:character_tag, name: "villain")

      expect(described_class.characters_with_tag("hero").map(&:character)).to eq([character])
    end
  end
end
