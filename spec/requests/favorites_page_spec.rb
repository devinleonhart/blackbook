# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Favorites page", type: :request do
  describe "GET index" do
    it "requires authentication" do
      get favorites_path

      expect(response).to redirect_to(new_user_session_path)
    end

    context "when signed in" do
      include_context "with a signed-in owner"

      it "shows only the current user's favorites, grouped by universe" do
        universe_a = create(:universe, owner: owner, name: "Alpha")
        universe_b = create(:universe, owner: owner, name: "Beta")
        favorited_a = create(:image, universe: universe_a)
        favorited_b = create(:image, universe: universe_b)
        others_favorite = create(:image, universe: universe_a)

        create(:image_favorite, user: owner, image: favorited_a)
        create(:image_favorite, user: owner, image: favorited_b)
        create(:image_favorite, user: create(:user), image: others_favorite)

        get favorites_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Your Favorites", "Alpha", "Beta")
        expect(response.body).to include(edit_universe_image_path(universe_a, favorited_a))
        expect(response.body).to include(edit_universe_image_path(universe_b, favorited_b))
        expect(response.body).not_to include(edit_universe_image_path(universe_a, others_favorite))
      end
    end
  end
end
