# frozen_string_literal: true

require "rails_helper"

RSpec.describe Image, type: :model do
  it "is invalid without an attached file (in test env)" do
    image = build(:image)
    image.image_file.detach
    expect(image).not_to be_valid
    expect(image.errors[:image_file]).to be_present
  end

  it "favorited_by? returns false for nil user" do
    image = create(:image)
    expect(image.favorited_by?(nil)).to be(false)
  end

  it "favorited_by? returns true when an ImageFavorite exists" do
    user = create(:user)
    image = create(:image)
    create(:image_favorite, user: user, image: image)
    expect(image.favorited_by?(user)).to be(true)
  end
end

# == Schema Information
#
# Table name: images
#
#  id          :bigint           not null, primary key
#  caption     :text             default(""), not null
#  favorite    :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :integer          not null
#
# Indexes
#
#  index_images_on_universe_id  (universe_id)
#

RSpec.describe Image, type: :model do
  let(:user) { create(:user) }
  let(:universe) { create(:universe, owner: user) }
  let(:image) { create(:image, universe: universe) }

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
      new_image.image_file.purge
      expect(new_image).not_to be_valid
      expect(new_image.errors[:image_file]).to include("must have an attached file")
    end
  end

  describe "callbacks" do
    it "sets a random filename after creation" do
      image.save!
      expect(image.image_file.blob.filename.to_s).not_to eq("test_image.jpg")
      expect(image.image_file.blob.filename.to_s).to match(/\A[0-9a-f-]+\.jpg\z/)
    end
  end
end
