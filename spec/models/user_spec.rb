# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "associations" do
    it do
      expect(user).to have_many(:owned_universes)
        .class_name("Universe")
        .with_foreign_key("owner_id")
        .inverse_of(:owner)
        .dependent(:restrict_with_error)
    end

    it { is_expected.to have_many(:collaborations).dependent(:destroy).inverse_of(:user) }
    it { is_expected.to have_many(:contributor_universes).through(:collaborations).source(:universe) }
    it { is_expected.to have_many(:image_favorites).dependent(:destroy) }
    it { is_expected.to have_many(:favorite_images).through(:image_favorites).source(:image) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:display_name) }
    it { is_expected.to validate_presence_of(:encrypted_password) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:display_name).case_insensitive }

    it "does not allow admin to be nil" do
      user.admin = nil
      expect(user).not_to be_valid
      expect(user.errors[:admin]).to be_present
    end
  end
end
