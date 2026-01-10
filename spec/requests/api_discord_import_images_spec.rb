# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::DiscordImports::Images", type: :request do
  let(:headers) { { "ACCEPT" => "application/json" } }

  def with_env(key, value)
    old = ENV.fetch(key, nil)
    ENV[key] = value
    yield
  ensure
    ENV[key] = old
  end

  it "returns 500 when DISCORD_IMPORT_TOKEN is not configured" do
    with_env("DISCORD_IMPORT_TOKEN", "") do
      post "/api/discord_imports/images", params: {}, headers: headers
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  it "returns 401 when token is wrong" do
    with_env("DISCORD_IMPORT_TOKEN", "expected") do
      post "/api/discord_imports/images",
        params: { universe_code: "KH" },
        headers: headers.merge("Authorization" => "Bearer wrong")
      expect(response).to have_http_status(:unauthorized)
    end
  end

  it "returns 422 for invalid universe_code" do
    with_env("DISCORD_IMPORT_TOKEN", "expected") do
      post "/api/discord_imports/images",
        params: { universe_code: "NOPE", image_file: "x" },
        headers: headers.merge("Authorization" => "Bearer expected")
      expect(response).to have_http_status(:unprocessable_content)
      json = response.parsed_body
      expect(json["error"]).to include("universe_code")
      expect(json["allowed_universe_codes"]).to be_a(Array)
    end
  end

  it "returns 422 when image_file is missing" do
    with_env("DISCORD_IMPORT_TOKEN", "expected") do
      create(:universe, name: "Knighthood") # KH
      post "/api/discord_imports/images",
        params: { universe_code: "KH" },
        headers: headers.merge("Authorization" => "Bearer expected")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to include("image_file")
    end
  end

  it "creates an image for a valid universe code" do
    with_env("DISCORD_IMPORT_TOKEN", "expected") do
      universe = create(:universe, name: "Knighthood") # KH

      file_path = Rails.root.join("spec/fixtures/files/test_image.jpg")
      upload = Rack::Test::UploadedFile.new(file_path, "image/jpeg")

      expect do
        post "/api/discord_imports/images",
          params: { universe_code: "KH", caption: "hello", image_file: upload },
          headers: headers.merge("Authorization" => "Bearer expected")
      end.to change(Image, :count).by(1)

      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json["image_id"]).to be_present

      image = Image.find(json["image_id"])
      expect(image.universe_id).to eq(universe.id)
      expect(image.caption).to eq("hello")
      expect(image.image_file).to be_attached
    end
  end
end
