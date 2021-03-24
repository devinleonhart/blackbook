# frozen_string_literal: true

# == Schema Information
#
# Table name: image_tags
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#  image_id     :bigint           not null
#
# Indexes
#
#  index_image_tags_on_character_id               (character_id)
#  index_image_tags_on_character_id_and_image_id  (character_id,image_id) UNIQUE
#  index_image_tags_on_image_id                   (image_id)
#

require "rails_helper"

RSpec.describe ImageTag, type: :model do
  before do
    @universe = FactoryBot.create(:universe)
    @other_universe = FactoryBot.create(:universe)
    @character = FactoryBot.create(:character, { universe: @universe })
    @image1 = FactoryBot.create(:image, { universe: @universe })
    @image2 = FactoryBot.create(:image, { universe: @other_universe })
  end

  it "should create a valid image_tag" do
    @image_tag = build(:image_tag, character: @character, image: @image1)
    expect(@image_tag).to be_valid
  end

  it "should create be invalid when character is missing" do
    @image_tag = build(:image_tag, character: nil, image: @image1)
    expect(@image_tag).to be_invalid
  end

  it "should create be invalid when image is missing" do
    @image_tag = build(:image_tag, character: @character, image: nil)
    expect(@image_tag).to be_invalid
  end

  it "should not allow a duplicate image tag" do
    @image_tag1 = create(:image_tag, character: @character, image: @image1)
    @image_tag2 = build(:image_tag, character: @character, image: @image1)
    expect(@image_tag1).to be_valid
    expect(@image_tag2).to be_invalid
  end

  it "should not allow a the tagging of a character from a different universe" do
    @image_tag1 = build(:image_tag, character: @character, image: @image2)
    expect(@image_tag1).to be_invalid
    expect(@image_tag1.errors.full_messages).to eq(["The character and image must be from the same universe!"])
  end
end
