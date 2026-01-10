# frozen_string_literal: true

class ImageFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :image

  validates :user_id, uniqueness: { scope: :image_id }
end
