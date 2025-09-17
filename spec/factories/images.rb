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
FactoryBot.define do
  factory :image do
    universe
    favorite { false }

    after(:build) do |image|
      file_path = Rails.root.join('spec/fixtures/files/test_image.jpg')
      image.image_file.attach(
        io: File.open(file_path),
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
    end

    # Factory for seeding without file attachments
    factory :image_for_seeding do
      universe
      favorite { false }

      # No file attachment for seeding - validation is skipped during seeding
    end
  end
end
