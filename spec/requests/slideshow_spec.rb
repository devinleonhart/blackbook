# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Slideshow", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "redirects unauthenticated users from the slideshow page" do
    get slideshow_path
    expect(response).to have_http_status(:found)
  end

  it "renders the slideshow page for authenticated users" do
    user = create(:user, email: "slideshow@example.com")
    sign_in_as(user)

    get slideshow_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Slideshow")
  end

  it "redirects unauthenticated users from the slideshow images endpoint" do
    get slideshow_images_path(mode: "all")
    expect(response).to have_http_status(:found)
  end

  it "returns only accessible images for mode=all" do
    user = create(:user, email: "user1@example.com")
    other_user = create(:user, email: "user2@example.com")

    accessible_universe = create(:universe, owner: user, name: "Accessible Universe")
    inaccessible_universe = create(:universe, owner: other_user, name: "Inaccessible Universe")

    accessible_image = create(:image, universe: accessible_universe)
    inaccessible_image = create(:image, universe: inaccessible_universe)

    sign_in_as(user)

    get slideshow_images_path(mode: "all")
    expect(response).to have_http_status(:ok)

    data = JSON.parse(response.body)
    ids = data.fetch("slides").map { |s| s.fetch("id") }
    expect(ids).to include(accessible_image.id)
    expect(ids).not_to include(inaccessible_image.id)
  end

  it "returns only favorited images for the current user, and still enforces universe accessibility" do
    user = create(:user, email: "favuser@example.com")
    other_user = create(:user, email: "other@example.com")

    accessible_universe = create(:universe, owner: user, name: "Accessible Universe")
    inaccessible_universe = create(:universe, owner: other_user, name: "Inaccessible Universe")

    favorited_accessible = create(:image, universe: accessible_universe)
    not_favorited_accessible = create(:image, universe: accessible_universe)
    favorited_inaccessible = create(:image, universe: inaccessible_universe)

    create(:image_favorite, user: user, image: favorited_accessible)
    create(:image_favorite, user: user, image: favorited_inaccessible) # excluded by universe access
    create(:image_favorite, user: other_user, image: favorited_accessible) # other user's favorite doesn't matter

    sign_in_as(user)

    get slideshow_images_path(mode: "favorites")
    expect(response).to have_http_status(:ok)

    data = JSON.parse(response.body)
    ids = data.fetch("slides").map { |s| s.fetch("id") }

    expect(ids).to include(favorited_accessible.id)
    expect(ids).not_to include(not_favorited_accessible.id)
    expect(ids).not_to include(favorited_inaccessible.id)
  end
end
