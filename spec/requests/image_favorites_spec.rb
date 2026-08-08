# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Image favorites", type: :request do
  include_context "with a signed-in owner"

  let(:image) { create(:image, universe: universe) }

  describe "PATCH update (favoriting)" do
    it "is idempotent when favoriting the same image twice" do
      expect do
        patch universe_image_path(universe, image), params: { image: { favorite: true } }
      end.to change(ImageFavorite, :count).by(1)
      expect(response).to redirect_to(edit_universe_image_url(universe, image))

      expect do
        patch universe_image_path(universe, image), params: { image: { favorite: true } }
      end.not_to change(ImageFavorite, :count)
    end

    it "is idempotent when unfavoriting an image that is not favorited" do
      expect do
        patch universe_image_path(universe, image), params: { image: { favorite: false } }
      end.not_to change(ImageFavorite, :count)

      expect(response).to redirect_to(edit_universe_image_url(universe, image))
    end
  end

  describe "PATCH update as a Turbo Stream (grid quick-favorite)" do
    let(:turbo_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

    it "favorites in place and returns the updated toggle" do
      expect do
        patch universe_image_path(universe, image), params: { image: { favorite: true } }, headers: turbo_headers
      end.to change(ImageFavorite, :count).by(1)

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("favorite_toggle_#{image.id}")
      expect(response.body).to include("Unfavorite")
    end

    it "unfavorites in place and returns the updated toggle" do
      ImageFavorite.create!(user: owner, image: image)

      expect do
        patch universe_image_path(universe, image), params: { image: { favorite: false } }, headers: turbo_headers
      end.to change(ImageFavorite, :count).by(-1)

      expect(response.body).to include("favorite_toggle_#{image.id}")
      expect(response.body).to include("Favorite")
    end
  end

  describe "the grid star on the universe page" do
    it "renders a filled star for favorited images and an empty star otherwise" do
      favorited = create(:image, universe: universe)
      create(:image, universe: universe) # not favorited
      ImageFavorite.create!(user: owner, image: favorited)

      get universe_path(universe)

      expect(response.body).to include("bb-fav-toggle--on")
      expect(response.body).to include("☆")
      expect(response.body).to include("★")
    end
  end

  describe "per-user isolation" do
    it "keeps favorites independent between users" do
      collaborator = create(:user)
      create(:collaboration, universe: universe, user: collaborator)

      patch universe_image_path(universe, image), params: { image: { favorite: true } }
      expect(image.reload.favorited_by?(owner)).to be(true)
      expect(image.favorited_by?(collaborator)).to be(false)

      sign_in(collaborator)
      patch universe_image_path(universe, image), params: { image: { favorite: true } }
      expect(image.reload.favorited_by?(owner)).to be(true)
      expect(image.favorited_by?(collaborator)).to be(true)

      sign_in(owner)
      patch universe_image_path(universe, image), params: { image: { favorite: false } }
      expect(image.reload.favorited_by?(owner)).to be(false)
      expect(image.favorited_by?(collaborator)).to be(true)
    end
  end
end
