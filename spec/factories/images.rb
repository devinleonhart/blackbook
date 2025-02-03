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
