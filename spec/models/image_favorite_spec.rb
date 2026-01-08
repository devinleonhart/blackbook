# frozen_string_literal: true

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
