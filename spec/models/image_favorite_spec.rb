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
require "rails_helper"

RSpec.describe ImageFavorite, type: :model do
  subject(:favorite) { build(:image_favorite) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:image) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:image_id) }
  end
end
