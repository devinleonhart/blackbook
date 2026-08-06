# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Random image", type: :request do
  include_context "with a signed-in owner"

  describe "GET random" do
    it "streams a random image from a universe the user can access" do
      accessible_image = create(:image, universe: universe)
      create(:image, universe: create(:universe, owner: create(:user))) # inaccessible

      get random_image_path

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq(accessible_image.image_file.content_type)
      expect(response.body).to eq(accessible_image.image_file.download)
    end

    it "returns 404 when the user has no accessible images" do
      get random_image_path

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("No images available")
    end
  end
end
