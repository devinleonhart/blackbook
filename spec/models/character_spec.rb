# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  universe_id  :bigint           not null
#
# Indexes
#
#  index_characters_on_discarded_at          (discarded_at)
#  index_characters_on_name_and_universe_id  (name,universe_id) UNIQUE
#  index_characters_on_universe_id           (universe_id)
#
# Foreign Keys
#
#  fk_rails_...  (universe_id => universes.id)
#
require "rails_helper"

RSpec.describe Character, type: :model do
  subject(:character) { build(:character) }

  describe "associations" do
    it { is_expected.to belong_to(:universe).inverse_of(:characters) }
    it { is_expected.to have_many(:image_tags).inverse_of(:character).dependent(:destroy) }
    it { is_expected.to have_many(:images).through(:image_tags).inverse_of(:characters) }
    it { is_expected.to have_many(:character_tags).inverse_of(:character).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "enforces case-insensitive uniqueness of name scoped to universe" do
      universe = create(:universe)
      create(:character, universe: universe, name: "Sora")

      dupe = build(:character, universe: universe, name: "sora")
      expect(dupe).not_to be_valid
      expect(dupe.errors[:name]).to be_present
    end
  end
end
