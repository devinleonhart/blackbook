# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Random image", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "streams a random image from universes accessible to the current user" do
    user = create(:user, email: "user1@example.com")
    other_user = create(:user, email: "user2@example.com")

    accessible_universe = create(:universe, owner: user, name: "Accessible Universe")
    inaccessible_universe = create(:universe, owner: other_user, name: "Inaccessible Universe")

    accessible_image = create(:image, universe: accessible_universe)
    _inaccessible_image = create(:image, universe: inaccessible_universe)

    sign_in_as(user)

    get random_image_path

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq(accessible_image.image_file.content_type)
    expect(response.body).to eq(accessible_image.image_file.download)
  end

  it "returns 404 when the user has no accessible images" do
    user = create(:user, email: "noimages@example.com")

    sign_in_as(user)

    get random_image_path

    expect(response).to have_http_status(:not_found)
    expect(response.body).to include("No images available")
  end
end
