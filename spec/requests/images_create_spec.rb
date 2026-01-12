# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images#create", type: :request do
  let(:user) { create(:user) }
  let(:universe) { create(:universe, owner: user) }
  let(:file_path) { Rails.root.join("spec/fixtures/files/test_image.jpg") }

  before { sign_in(user) }

  describe "single file upload" do
    it "creates a single image and redirects to edit page" do
      upload = Rack::Test::UploadedFile.new(file_path, "image/jpeg")

      expect do
        post universe_images_path(universe), params: { image: { image_file: upload } }
      end.to change(Image, :count).by(1)

      expect(response).to redirect_to(edit_universe_image_path(universe, Image.last))
      expect(flash[:success]).to eq("Image created!")
    end
  end

  describe "multiple file upload" do
    it "creates multiple images and redirects to universe page" do
      upload1 = Rack::Test::UploadedFile.new(file_path, "image/jpeg")
      upload2 = Rack::Test::UploadedFile.new(file_path, "image/jpeg")
      upload3 = Rack::Test::UploadedFile.new(file_path, "image/jpeg")

      expect do
        post universe_images_path(universe),
             params: { image: { image_file: [upload1, upload2, upload3] } }
      end.to change(Image, :count).by(3)

      expect(response).to redirect_to(universe_path(universe))
      expect(flash[:success]).to eq("3 images created!")
    end
  end

  describe "edge cases" do
    it "handles empty file array" do
      expect do
        post universe_images_path(universe), params: { image: { image_file: [] } }
      end.not_to change(Image, :count)

      expect(response).to redirect_to(universe_path(universe))
      expect(flash[:error]).to eq("No images were selected.")
    end

    it "handles nil file parameter" do
      expect do
        post universe_images_path(universe), params: { image: { image_file: nil } }
      end.not_to change(Image, :count)

      expect(response).to redirect_to(universe_path(universe))
      expect(flash[:error]).to eq("No images were selected.")
    end

    it "handles blank files in array" do
      valid_upload = Rack::Test::UploadedFile.new(file_path, "image/jpeg")

      expect do
        post universe_images_path(universe),
             params: { image: { image_file: [valid_upload, nil, ""] } }
      end.to change(Image, :count).by(1)

      # When only 1 image is created, redirects to edit page
      expect(response).to redirect_to(edit_universe_image_path(universe, Image.last))
      expect(flash[:success]).to eq("Image created!")
    end
  end

  describe "authorization" do
    it "prevents non-collaborators from uploading multiple images" do
      owner = create(:user)
      universe = create(:universe, owner: owner)
      stranger = create(:user)

      upload1 = Rack::Test::UploadedFile.new(file_path, "image/jpeg")
      upload2 = Rack::Test::UploadedFile.new(file_path, "image/jpeg")

      sign_in(stranger)
      expect do
        post universe_images_path(universe),
             params: { image: { image_file: [upload1, upload2] } }
      end.not_to change(Image, :count)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to include("owner or collaborator")
    end

    it "allows collaborators to upload multiple images" do
      owner = create(:user)
      universe = create(:universe, owner: owner)
      collaborator = create(:user)
      create(:collaboration, universe: universe, user: collaborator)

      upload1 = Rack::Test::UploadedFile.new(file_path, "image/jpeg")
      upload2 = Rack::Test::UploadedFile.new(file_path, "image/jpeg")

      sign_in(collaborator)
      expect do
        post universe_images_path(universe),
             params: { image: { image_file: [upload1, upload2] } }
      end.to change(Image, :count).by(2)

      expect(response).to redirect_to(universe_path(universe))
      expect(flash[:success]).to eq("2 images created!")
    end
  end
end
