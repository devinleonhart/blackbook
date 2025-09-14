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

class ImageTag < ApplicationRecord
  validates :character, uniqueness: { scope: :image_id }

  validate :character_must_be_from_same_universe_as_image

  belongs_to :character, inverse_of: :image_tags
  belongs_to :image, inverse_of: :image_tags

  delegate :universe, to: :character, allow_nil: true

  # Update image filename when character tags change
  after_create :update_image_filename
  after_destroy :update_image_filename

  private

  def character_must_be_from_same_universe_as_image
    return if character.nil? || image.nil?

    errors.add(:base, "The character and image must be from the same universe!") if character.universe != image.universe
  end

  def update_image_filename
    return unless image&.respond_to?(:update_local_filename!)

    # Use a background job or delay to avoid blocking the main request
    # For now, update synchronously
    begin
      image.update_local_filename!
    rescue => e
      Rails.logger.error("Failed to update image filename for image #{image.id}: #{e.message}")
    end
  end
end
