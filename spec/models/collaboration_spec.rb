# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaboration, type: :model do
  subject(:collaboration) { build(:collaboration, universe: universe, user: user) }

  let(:owner) { create(:user) }
  let(:universe) { create(:universe, owner: owner) }
  let(:user) { create(:user) }

  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:collaborations) }
    it { is_expected.to belong_to(:universe).inverse_of(:collaborations) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:universe_id) }

    it "does not allow the owner to collaborate on their own universe" do
      collaboration.user = owner
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:user]).to be_present
    end
  end
end
