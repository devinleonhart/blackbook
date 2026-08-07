# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :bigint           not null
#
# Indexes
#
#  index_images_on_universe_id  (universe_id)
#
FactoryBot.define do
  factory :image do
    universe

    after(:build) do |image|
      file_path = Rails.root.join("spec/fixtures/files/test_image.jpg")
      image.image_file.attach(
        io: File.open(file_path),
        filename: "test_image.jpg",
        content_type: "image/jpeg"
      )
    end
  end
end
