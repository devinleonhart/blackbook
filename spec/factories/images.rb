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

FactoryBot.define do
  factory :image do
    image_file do
      Rack::Test::UploadedFile.new("spec/fixtures/image.png", "image/png")
    end
  end
end
