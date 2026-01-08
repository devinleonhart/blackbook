# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images view", type: :request do
  it "streams an image without authentication" do
    image = create(:image)

    get view_image_path(image.id, image.image_file.filename.to_s)

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq(image.image_file.content_type)
    expect(response.headers["Cache-Control"]).to include("max-age")
    expect(response.body).to eq(image.image_file.download)
  end
end
