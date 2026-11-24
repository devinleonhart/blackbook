# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id          :bigint           not null, primary key
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

  has_many :appearances, inverse_of: :image, dependent: :destroy
  has_many :characters, through: :appearances
  has_many :image_favorites, dependent: :destroy, inverse_of: :image

  belongs_to :universe, inverse_of: :images

  scope :untagged, -> { where.missing(:appearances) }

  # Tags those of the characters that belong to the universe and are not tagged yet, and gives their number.
  def tag_characters(ids)
    new_ids = universe.characters.where(id: ids).where.not(id: appearances.select(:character_id)).ids
    new_ids.count { |id| appearances.create(character_id: id).persisted? }
  end

  def favorite_by(user)
    image_favorites.find_or_create_by!(user: user)
  end

  def unfavorite_by(user)
    image_favorites.where(user: user).destroy_all
  end

  def favorited_by?(user)
    return false if user.nil?

    image_favorites.exists?(user_id: user.id)
  end

  private

  def requires_image_attached
    errors.add(:image_file, "must have an attached file") unless image_file.attached?
  rescue ActiveSupport::MessageVerifier::InvalidSignature => error
    errors.add(:image_file, "has invalid data (#{error.message})")
  end

  def set_filename
    image_file.blob.update!(filename: "#{SecureRandom.uuid}.#{image_file.filename.extension}") if image_file.attached?
  end
end
