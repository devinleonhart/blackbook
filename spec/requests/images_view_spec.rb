# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images view", type: :request do
  describe "GET view" do
    it "streams the image bytes without requiring authentication" do
      image = create(:image)

      get view_image_path(image.id, image.image_file.filename.to_s)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq(image.image_file.content_type)
      expect(response.headers["Cache-Control"]).to include("max-age")
      expect(response.body).to eq(image.image_file.download)
    end

    it "returns 404 when the filename does not match the stored file (no id enumeration)" do
      image = create(:image)

      get view_image_path(image.id, "guessed-from-the-integer.png")

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a non-existent image id" do
      get view_image_path(id: 999_999, filename: "whatever.png")

      expect(response).to have_http_status(:not_found)
    end
  end
end
