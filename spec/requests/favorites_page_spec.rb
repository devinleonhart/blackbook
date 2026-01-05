# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Favorites page", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "requires authentication" do
    get favorites_path
    expect(response).to have_http_status(:found)
  end

  it "shows only the current user's favorites, grouped by universe" do
    user = create(:user, password: "password123")
    other_user = create(:user, password: "password123")

    universe_a = create(:universe, owner: user, name: "Alpha")
    universe_b = create(:universe, owner: user, name: "Beta")

    img_a1 = create(:image, universe: universe_a)
    img_b1 = create(:image, universe: universe_b)
    img_a2 = create(:image, universe: universe_a)

    create(:image_favorite, user: user, image: img_a1)
    create(:image_favorite, user: user, image: img_b1)

    # Other user's favorite should not show up
    create(:image_favorite, user: other_user, image: img_a2)

    sign_in_as(user)
    get favorites_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Your Favorites")

    # Universes shown
    expect(response.body).to include("Alpha")
    expect(response.body).to include("Beta")

    # Only user's favorited images are linked
    expect(response.body).to include(edit_universe_image_path(universe_a, img_a1))
    expect(response.body).to include(edit_universe_image_path(universe_b, img_b1))
    expect(response.body).not_to include(edit_universe_image_path(universe_a, img_a2))
  end
end
