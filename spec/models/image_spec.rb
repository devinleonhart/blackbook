# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  caption    :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe Image, type: :model do
  it { should respond_to(:caption) }

  describe "validations" do
    describe "requires_image_attached" do
      context "when no image file is attached" do
        let(:image) { build :image, image_file: nil }

        it "should raise an error" do
          image.valid?
          expect(image.errors[:image_file]).to(
            eq(["must have an attached file"])
          )
        end
      end

      context "when an image file is attached" do
        let(:image) { build :image }

        it "shouldn't raise an error" do
          image.valid?
          expect(image.errors[:image_file]).to be_empty
        end
      end
    end
  end

  it {
    should(
      have_many(:image_tags)
      .inverse_of(:image)
      .dependent(:destroy)
    )
  }
  it {
    should(
      have_many(:characters)
      .through(:image_tags)
      .inverse_of(:images)
    )
  }
end
