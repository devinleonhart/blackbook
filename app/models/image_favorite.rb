# frozen_string_literal: true

# == Schema Information
#
# Table name: image_favorites
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  image_id   :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ImageFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :image

  validates :user_id, uniqueness: { scope: :image_id }
end
