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

  describe "PATCH update as JSON (slideshow favorite)" do
    it "favorites and returns the new state" do
      expect do
        patch universe_image_path(universe, image), params: { image: { favorite: true } }, as: :json
      end.to change(ImageFavorite, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("favorited" => true)
    end

    it "unfavorites and returns the new state" do
      ImageFavorite.create!(user: owner, image: image)

      patch universe_image_path(universe, image), params: { image: { favorite: false } }, as: :json

      expect(response.parsed_body).to eq("favorited" => false)
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
