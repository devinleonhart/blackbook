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
      image.image_file.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test_image.jpg')),
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end
