# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Image favorites", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "favorites are per-user (one user's favorite does not affect another user)" do
    owner = create(:user, password: "password123")
    collaborator = create(:user, password: "password123")
    universe = create(:universe, owner: owner)
    create(:collaboration, universe: universe, user: collaborator)
    image = create(:image, universe: universe)

    # Owner favorites
    sign_in_as(owner)
    patch universe_image_path(universe, image), params: { image: { favorite: true } }
    expect(response).to have_http_status(:found)

    expect(image.reload.favorited_by?(owner)).to eq(true)
    expect(image.favorited_by?(collaborator)).to eq(false)

    # Collaborator favorites (independently)
    delete destroy_user_session_path
    sign_in_as(collaborator)
    patch universe_image_path(universe, image), params: { image: { favorite: true } }
    expect(response).to have_http_status(:found)

    expect(image.reload.favorited_by?(owner)).to eq(true)
    expect(image.favorited_by?(collaborator)).to eq(true)

    # Owner unfavorites; collaborator stays favorited
    delete destroy_user_session_path
    sign_in_as(owner)
    patch universe_image_path(universe, image), params: { image: { favorite: false } }
    expect(response).to have_http_status(:found)

    expect(image.reload.favorited_by?(owner)).to eq(false)
    expect(image.favorited_by?(collaborator)).to eq(true)
  end
end
