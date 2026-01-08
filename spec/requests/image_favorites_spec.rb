# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Image favorites", type: :request do
  it "favorites are per-user (one user's favorite does not affect another user)" do
    owner = create(:user)
    collaborator = create(:user)
    universe = create(:universe, owner: owner)
    create(:collaboration, universe: universe, user: collaborator)
    image = create(:image, universe: universe)

    # Owner favorites
    sign_in(owner)
    patch universe_image_path(universe, image), params: { image: { favorite: true } }
    expect(response).to have_http_status(:found)

    expect(image.reload.favorited_by?(owner)).to be(true)
    expect(image.favorited_by?(collaborator)).to be(false)

    # Collaborator favorites (independently)
    delete destroy_user_session_path
    sign_in(collaborator)
    patch universe_image_path(universe, image), params: { image: { favorite: true } }
    expect(response).to have_http_status(:found)

    expect(image.reload.favorited_by?(owner)).to be(true)
    expect(image.favorited_by?(collaborator)).to be(true)

    # Owner unfavorites; collaborator stays favorited
    delete destroy_user_session_path
    sign_in(owner)
    patch universe_image_path(universe, image), params: { image: { favorite: false } }
    expect(response).to have_http_status(:found)

    expect(image.reload.favorited_by?(owner)).to be(false)
    expect(image.favorited_by?(collaborator)).to be(true)
  end
end
