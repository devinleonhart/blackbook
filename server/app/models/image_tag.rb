# frozen_string_literal: true

# == Schema Information
#
# Table name: image_tags
#
#  id           :bigint           not null, primary key
#  character_id :bigint           not null
#  image_id     :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ImageTag < ApplicationRecord
  validates :character, uniqueness: { scope: :image_id }

  belongs_to :character, inverse_of: :image_tags
  belongs_to :image, inverse_of: :image_tags

  delegate :universe, to: :character, allow_nil: true
end
