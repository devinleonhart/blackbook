# frozen_string_literal: true

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

  describe ".all_tag_names" do
    it "returns sorted unique tag names" do
      create(:character_tag, name: "elf")
      create(:character_tag, name: "human")
      create(:character_tag, name: "elf")

      expect(described_class.all_tag_names).to eq(%w[elf human])
    end
  end

  describe ".tag_exists?" do
    it "returns true when the tag exists" do
      create(:character_tag, name: "warrior")
      expect(described_class.tag_exists?("warrior")).to be(true)
    end

    it "returns false when the tag does not exist" do
      expect(described_class.tag_exists?("does-not-exist")).to be(false)
    end
  end
end
