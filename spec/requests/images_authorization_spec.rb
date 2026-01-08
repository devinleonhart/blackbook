# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images authorization", type: :request do
  it "prevents non-collaborators from creating images in someone else's universe" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    stranger = create(:user)

    file_path = Rails.root.join("spec/fixtures/files/test_image.jpg")
    upload = Rack::Test::UploadedFile.new(file_path, "image/jpeg")

    sign_in(stranger)
    expect do
      post universe_images_path(universe), params: { image: { image_file: upload } }
    end.not_to change(Image, :count)

    expect(response).to redirect_to(universes_url)
    expect(flash[:error]).to include("owner or collaborator")
  end

  it "prevents non-collaborators from deleting images in someone else's universe" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    image = create(:image, universe: universe)
    stranger = create(:user)

    sign_in(stranger)
    expect do
      delete universe_image_path(universe, image)
    end.not_to change(Image, :count)

    expect(response).to redirect_to(universes_url)
    expect(flash[:error]).to include("owner or collaborator")
  end
end
