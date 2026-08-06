# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::DiscordImports::Images", type: :request do
  let(:headers) { { "ACCEPT" => "application/json" } }
  let(:upload) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test_image.jpg"), "image/jpeg") }

  def with_env(key, value)
    old = ENV.fetch(key, nil)
    ENV[key] = value
    yield
  ensure
    ENV[key] = old
  end

  def post_import(params, token: "expected")
    post "/api/discord_imports/images",
         params: params,
         headers: headers.merge("Authorization" => "Bearer #{token}")
  end

  describe "POST create" do
    context "when the import token is not configured" do
      it "returns 500" do
        with_env("DISCORD_IMPORT_TOKEN", "") do
          post "/api/discord_imports/images", params: {}, headers: headers
        end

        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context "when the import token is configured" do
      around { |example| with_env("DISCORD_IMPORT_TOKEN", "expected") { example.run } }

      it "returns 401 for a wrong token" do
        post_import({ universe_code: "KH" }, token: "wrong")

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns 422 for an invalid universe_code" do
        post_import({ universe_code: "NOPE", image_file: "x" })

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["error"]).to include("universe_code")
        expect(response.parsed_body["allowed_universe_codes"]).to be_a(Array)
      end

      it "returns 422 when image_file is missing" do
        create(:universe, name: "Knighthood") # KH

        post_import({ universe_code: "KH" })

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["error"]).to include("image_file")
      end

      it "returns 422 when no universe exists for a valid code" do
        # "KH" maps to "Knighthood", but no such universe exists.
        post_import({ universe_code: "KH", image_file: upload })

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["error"]).to include("Universe not found")
      end

      it "returns 422 when the image cannot be saved" do
        create(:universe, name: "Knighthood")
        unsaved = Image.new
        allow(unsaved).to receive(:save).and_return(false)
        allow(Image).to receive(:new).and_return(unsaved)

        post_import({ universe_code: "KH", image_file: upload })

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "creates an image for a valid universe code" do
        universe = create(:universe, name: "Knighthood") # KH

        expect do
          post_import({ universe_code: "KH", caption: "hello", image_file: upload })
        end.to change(Image, :count).by(1)

        expect(response).to have_http_status(:created)
        image = Image.find(response.parsed_body.fetch("image_id"))
        expect(image.universe_id).to eq(universe.id)
        expect(image.caption).to eq("hello")
        expect(image.image_file).to be_attached
      end
    end
  end
end
