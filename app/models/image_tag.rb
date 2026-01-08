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
class ImageTag < ApplicationRecord
  validates :character, uniqueness: { scope: :image_id }

  validate :character_must_be_from_same_universe_as_image

  belongs_to :character, inverse_of: :image_tags
  belongs_to :image, inverse_of: :image_tags

  delegate :universe, to: :character, allow_nil: true

  private

  def character_must_be_from_same_universe_as_image
    return if character.nil? || image.nil?

    errors.add(:base, "The character and image must be from the same universe!") if character.universe != image.universe
  end
end
