# frozen_string_literal: true

# == Schema Information
#
# Table name: image_favorites
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_image_favorites_on_image_id              (image_id)
#  index_image_favorites_on_user_id               (user_id)
#  index_image_favorites_on_user_id_and_image_id  (user_id,image_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (image_id => images.id)
#  fk_rails_...  (user_id => users.id)
#
class ImageFavorite < ApplicationRecord
  belongs_to :user, inverse_of: :image_favorites
  belongs_to :image, inverse_of: :image_favorites

  validates :user_id, uniqueness: { scope: :image_id }
end
