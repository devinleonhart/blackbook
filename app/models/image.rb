# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id          :bigint           not null, primary key
#  caption     :text             default(""), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :bigint           not null
#
# Indexes
#
#  index_images_on_universe_id  (universe_id)
#
class Image < ApplicationRecord
  after_create :set_filename
  validate :requires_image_attached

  has_one_attached :image_file

  has_many :image_tags, inverse_of: :image, dependent: :destroy
  has_many :characters, through: :image_tags, inverse_of: :images
  has_many :image_favorites, dependent: :destroy
  has_many :favorited_by_users, through: :image_favorites, source: :user

  belongs_to :universe, inverse_of: :images

  scope :untagged, -> { where.missing(:image_tags) }

  def favorited_by?(user)
    return false if user.nil?

    image_favorites.exists?(user_id: user.id)
  end

  private

  def requires_image_attached
    # Skip validation during seeding to avoid file descriptor issues
    return if Rails.env.development? && caller.any? { |line| line.include?("db/seeds.rb") }

    errors.add(:image_file, "must have an attached file") unless image_file.attached?
  rescue ActiveSupport::MessageVerifier::InvalidSignature => error
    errors.add(:image_file, "has invalid data (#{error.message})")
  end

  def set_filename
    image_file.blob.update!(filename: "#{SecureRandom.uuid}.#{image_file.filename.extension}") if image_file.attached?
  end
end
