# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id          :bigint           not null, primary key
#  caption     :text             default(""), not null
#  universe_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "rails_helper"
RSpec.describe Image, type: :model do
  subject(:image) { create(:image, universe: universe) }

  let(:owner) { create(:user) }
  let(:universe) { create(:universe, owner: owner) }

  describe "associations" do
    it { is_expected.to belong_to(:universe).inverse_of(:images) }
    it { is_expected.to have_many(:image_tags).dependent(:destroy).inverse_of(:image) }
    it { is_expected.to have_many(:characters).through(:image_tags).inverse_of(:images) }
    it { is_expected.to have_one_attached(:image_file) }
  end

  describe "validations" do
    it "is valid with all required attributes" do
      expect(image).to be_valid
    end

    it "is invalid without an attached image file" do
      new_image = build(:image, universe: universe)
      new_image.image_file.detach
      expect(new_image).not_to be_valid
      expect(new_image.errors[:image_file]).to be_present
    end
  end

  describe "#favorited_by?" do
    it "returns false for nil user" do
      expect(image.favorited_by?(nil)).to be(false)
    end

    it "returns true when an ImageFavorite exists" do
      user = create(:user)
      create(:image_favorite, user: user, image: image)
      expect(image.favorited_by?(user)).to be(true)
    end
  end

  describe "callbacks" do
    it "sets a random filename after creation" do
      filename = image.image_file.blob.filename.to_s
      expect(filename).not_to eq("test_image.jpg")
      expect(filename).to match(/\A[0-9a-f-]+\.jpg\z/)
    end
  end
end
