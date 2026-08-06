# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images authorization", type: :request do
  let(:universe) { create(:universe, owner: create(:user)) }
  let(:stranger) { create(:user) }
  let(:upload) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test_image.jpg"), "image/jpeg") }

  before { sign_in(stranger) }

  describe "POST create" do
    it "prevents a non-collaborator from creating images in another user's universe" do
      expect do
        post universe_images_path(universe), params: { image: { image_file: upload } }
      end.not_to change(Image, :count)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to include("owner or collaborator")
    end
  end

  describe "DELETE destroy" do
    it "prevents a non-collaborator from deleting images in another user's universe" do
      image = create(:image, universe: universe)

      expect do
        delete universe_image_path(universe, image)
      end.not_to change(Image, :count)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to include("owner or collaborator")
    end
  end
end
