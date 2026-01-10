# frozen_string_literal: true

FactoryBot.define do
  factory :image_tag do
    association :character
    association :image

    # Ensure the image and character belong to the same universe
    after(:build) do |image_tag|
      image_tag.image.universe = image_tag.character.universe if image_tag.character && image_tag.image
    end
  end
end
