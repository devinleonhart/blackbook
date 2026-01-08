# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ImageTags", type: :request do
  it "redirects unauthenticated users" do
    universe = create(:universe)
    image = create(:image, universe: universe)
    post universe_image_image_tags_path(universe, image), params: { image_tag: { character_id: 123 } }
    expect(response).to have_http_status(:found)
  end

  it "creates an image tag and redirects to image edit" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    image = create(:image, universe: universe)

    sign_in(owner)

    expect do
      post universe_image_image_tags_path(universe, image), params: { image_tag: { character_id: character.id } }
    end.to change(ImageTag, :count).by(1)

    expect(response).to redirect_to(edit_universe_image_url(universe.id, image.id))
  end

  it "shows an image tag" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    image = create(:image, universe: universe)
    image_tag = create(:image_tag, image: image, character: character)

    sign_in(owner)
    get image_tag_path(image_tag)

    # There is no HTML template for this action today, so Rails returns 406.
    # (This still exercises the controller lookup + authorization paths.)
    expect(response).to have_http_status(:not_acceptable)
  end

  it "destroys an image tag and redirects back to image edit" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    image = create(:image, universe: universe)
    image_tag = create(:image_tag, image: image, character: character)

    sign_in(owner)

    expect do
      delete image_tag_path(image_tag)
    end.to change(ImageTag, :count).by(-1)

    expect(response).to redirect_to(edit_universe_image_url(universe.id, image.id))
  end
end
