# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Image favorites", type: :request do
  it "is idempotent when favoriting the same image twice" do
    user = create(:user)
    universe = create(:universe, owner: user)
    image = create(:image, universe: universe)

    sign_in(user)

    expect do
      patch universe_image_path(universe, image), params: { image: { favorite: true } }
    end.to change(ImageFavorite, :count).by(1)
    expect(response).to redirect_to(edit_universe_image_url(universe, image))

    expect do
      patch universe_image_path(universe, image), params: { image: { favorite: true } }
    end.not_to change(ImageFavorite, :count)
    expect(response).to redirect_to(edit_universe_image_url(universe, image))
  end

  it "is idempotent when unfavoriting an image that is not favorited" do
    user = create(:user)
    universe = create(:universe, owner: user)
    image = create(:image, universe: universe)

    sign_in(user)

    expect do
      patch universe_image_path(universe, image), params: { image: { favorite: false } }
    end.not_to change(ImageFavorite, :count)
    expect(response).to redirect_to(edit_universe_image_url(universe, image))
  end

  it "favorites are per-user (one user's favorite does not affect another user)" do
    owner = create(:user)
    collaborator = create(:user)
    universe = create(:universe, owner: owner)
    create(:collaboration, universe: universe, user: collaborator)
    image = create(:image, universe: universe)

    # Owner favorites
    sign_in(owner)
    patch universe_image_path(universe, image), params: { image: { favorite: true } }
    expect(response).to redirect_to(edit_universe_image_url(universe, image))

    expect(image.reload.favorited_by?(owner)).to be(true)
    expect(image.favorited_by?(collaborator)).to be(false)

    # Collaborator favorites (independently)
    sign_out(owner)
    sign_in(collaborator)
    patch universe_image_path(universe, image), params: { image: { favorite: true } }
    expect(response).to redirect_to(edit_universe_image_url(universe, image))

    expect(image.reload.favorited_by?(owner)).to be(true)
    expect(image.favorited_by?(collaborator)).to be(true)

    # Owner unfavorites; collaborator stays favorited
    sign_out(collaborator)
    sign_in(owner)
    patch universe_image_path(universe, image), params: { image: { favorite: false } }
    expect(response).to redirect_to(edit_universe_image_url(universe, image))

    expect(image.reload.favorited_by?(owner)).to be(false)
    expect(image.favorited_by?(collaborator)).to be(true)
  end
end
