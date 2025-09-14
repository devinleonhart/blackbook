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
require 'rails_helper'

RSpec.describe Image, type: :model do
  let(:user) { create(:user) }
  let(:universe) { create(:universe, owner: user) }
  let(:image) { create(:image, universe: universe) }

  describe "associations" do
    it { should belong_to(:universe).inverse_of(:images) }
    it { should have_many(:image_tags).dependent(:destroy).inverse_of(:image) }
    it { should have_many(:characters).through(:image_tags).inverse_of(:images) }
    it { should have_one_attached(:image_file) }
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
