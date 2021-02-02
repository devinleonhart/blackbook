# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  caption    :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Image < ApplicationRecord
  validate :requires_image_attached

  has_one_attached :image_file

  has_many :image_tags, inverse_of: :image, dependent: :destroy
  has_many :characters, through: :image_tags, inverse_of: :images

  private

  def requires_image_attached
    unless image_file.attached?
      errors.add(:image_file, "must have an attached file")
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature => error
    errors.add(:image_file, "has invalid data (#{error.message})")
  end
end
