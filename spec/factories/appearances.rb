# frozen_string_literal: true

# == Schema Information
#
# Table name: appearances
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#  image_id     :bigint           not null
#
# Indexes
#
#  index_appearances_on_character_id               (character_id)
#  index_appearances_on_character_id_and_image_id  (character_id,image_id) UNIQUE
#  index_appearances_on_image_id                   (image_id)
#
FactoryBot.define do
  factory :appearance do
    association :character
    association :image

    # Ensure the image and character belong to the same universe
    after(:build) do |appearance|
      appearance.image.universe = appearance.character.universe if appearance.character && appearance.image
    end
  end
end
