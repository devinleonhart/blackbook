# frozen_string_literal: true

# == Schema Information
#
# Table name: image_tags
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :integer          not null
#  image_id     :integer          not null
#
# Indexes
#
#  index_image_tags_on_character_id               (character_id)
#  index_image_tags_on_character_id_and_image_id  (character_id,image_id) UNIQUE
#  index_image_tags_on_image_id                   (image_id)
#

FactoryBot.define do
  factory :image_tag do
    character
    image
  end
end
