# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Random image", type: :request do
  include_context "with a signed-in owner"

  describe "GET random" do
    it "redirects to the detail page of a random accessible image" do
      accessible_image = create(:image, universe: universe)
      create(:image, universe: create(:universe, owner: create(:user))) # inaccessible

      get random_image_path

      expect(response).to redirect_to(edit_universe_image_url(universe, accessible_image))
    end

    it "redirects home with a notice when the user has no accessible images" do
      get random_image_path

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to include("No images available")
    end
  end
end
