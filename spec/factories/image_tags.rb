# frozen_string_literal: true

# == Schema Information
#
# Table name: image_tags
#
#  id           :bigint           not null, primary key
#  character_id :integer          not null
#  image_id     :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
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
