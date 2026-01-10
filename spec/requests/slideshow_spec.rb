# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Slideshow", type: :request do
  it "redirects unauthenticated users from the slideshow page" do
    get slideshow_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it "renders the slideshow page for authenticated users" do
    user = create(:user, email: "slideshow@example.com")
    sign_in(user)

    get slideshow_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Slideshow")
  end

  it "redirects unauthenticated users from the slideshow images endpoint" do
    get slideshow_images_path(mode: "all")
    expect(response).to redirect_to(new_user_session_path)
  end

  it "returns only accessible images for mode=all" do
    user = create(:user, email: "user1@example.com")
    other_user = create(:user, email: "user2@example.com")

    accessible_universe = create(:universe, owner: user, name: "Accessible Universe")
    inaccessible_universe = create(:universe, owner: other_user, name: "Inaccessible Universe")

    accessible_image = create(:image, universe: accessible_universe)
    inaccessible_image = create(:image, universe: inaccessible_universe)

    sign_in(user)

    get slideshow_images_path(mode: "all")
    expect(response).to have_http_status(:ok)

    data = response.parsed_body
    ids = data.fetch("slides").map { |s| s.fetch("id") }
    expect(ids).to include(accessible_image.id)
    expect(ids).not_to include(inaccessible_image.id)
  end

  it "supports filtering slides by universe_id" do
    user = create(:user, email: "user1@example.com")
    accessible_universe = create(:universe, owner: user, name: "U1")
    other_accessible_universe = create(:universe, owner: user, name: "U2")

    included = create(:image, universe: accessible_universe)
    excluded = create(:image, universe: other_accessible_universe)

    sign_in(user)

    get slideshow_images_path(mode: "all", universe_id: accessible_universe.id)
    expect(response).to have_http_status(:ok)

    ids = response.parsed_body.fetch("slides").map { |s| s.fetch("id") }
    expect(ids).to include(included.id)
    expect(ids).not_to include(excluded.id)
  end

  it "returns 404 when filtering to an inaccessible universe" do
    user = create(:user, email: "user1@example.com")
    other_user = create(:user, email: "user2@example.com")

    accessible_universe = create(:universe, owner: user, name: "Accessible Universe")
    inaccessible_universe = create(:universe, owner: other_user, name: "Inaccessible Universe")

    create(:image, universe: accessible_universe)
    create(:image, universe: inaccessible_universe)

    sign_in(user)

    get slideshow_images_path(mode: "all", universe_id: inaccessible_universe.id)
    expect(response).to have_http_status(:not_found)
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

    sign_in(user)

    get slideshow_images_path(mode: "favorites")
    expect(response).to have_http_status(:ok)

    data = response.parsed_body
    ids = data.fetch("slides").map { |s| s.fetch("id") }

    expect(ids).to include(favorited_accessible.id)
    expect(ids).not_to include(not_favorited_accessible.id)
    expect(ids).not_to include(favorited_inaccessible.id)
  end
end
