# frozen_string_literal: true

# == Schema Information
#
# Table name: universes
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :citext           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :bigint           not null
#
# Indexes
#
#  index_universes_on_discarded_at       (discarded_at)
#  index_universes_on_name               (name) UNIQUE
#  index_universes_on_name_and_owner_id  (name,owner_id) UNIQUE
#  index_universes_on_owner_id           (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
require "rails_helper"

RSpec.describe Universe, type: :model do
  subject(:universe) { build(:universe, owner: owner) }

  let(:owner) { create(:user) }

  describe "associations" do
    it { is_expected.to belong_to(:owner).class_name("User").inverse_of(:owned_universes) }
    it { is_expected.to have_many(:collaborations).inverse_of(:universe).dependent(:destroy) }
    it { is_expected.to have_many(:collaborators).through(:collaborations).source(:user) }
    it { is_expected.to have_many(:characters).inverse_of(:universe).dependent(:destroy) }
    it { is_expected.to have_many(:images).inverse_of(:universe).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "enforces case-insensitive uniqueness of name scoped to owner" do
      create(:universe, owner: owner, name: "My Universe")
      dupe = build(:universe, owner: owner, name: "my universe")
      expect(dupe).not_to be_valid
      expect(dupe.errors[:name]).to be_present
    end
  end

  describe "#visible_to_user?" do
    it "returns true for the owner" do
      expect(universe.visible_to_user?(owner)).to be(true)
    end

    it "returns true for a collaborator" do
      collaborator = create(:user)
      universe.save!
      create(:collaboration, universe: universe, user: collaborator)

      expect(universe.visible_to_user?(collaborator)).to be(true)
    end

    it "returns false for a stranger" do
      stranger = create(:user)
      universe.save!

      expect(universe.visible_to_user?(stranger)).to be(false)
    end
  end
end
