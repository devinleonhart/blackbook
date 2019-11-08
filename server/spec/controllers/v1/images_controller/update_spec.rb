# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::ImagesController, type: :controller do
  render_views

  let!(:image) { create :image, caption: "A great pic." }
  let!(:character) { create :character }

  before do
    image.characters << character
    image.save!
  end

  describe "PUT/PATCH update" do
    subject { put(:update, format: :json, params: params) }

    context "when the user is authenticated" do
      before { authenticate(create(:user)) }

      context "when the image exists" do
        context "when the parameters are valid" do
          let(:params) do
            {
              id: image.id,
              image: { caption: "Stormy weather." },
            }
          end

          include_examples "returns a success HTTP status code"

          it "updates the image's caption" do
            subject
            expect(image.reload.caption).to eq("Stormy weather.")
          end

          it "returns the image's ID" do
            subject
            expect(json["image"]["id"]).to eq(image.id)
          end

          it "returns the image's new caption" do
            subject
            expect(json["image"]["caption"]).to eq("Stormy weather.")
          end

          it "returns the image file's URL" do
            subject
            expect(json["image"]["image_url"]).to eq(
              Rails.application.routes.url_helpers.rails_blob_path(
                image.reload.image_file,
                only_path: true,
              )
            )
          end

          it "returns only the characters that are visible to the current user" do
            subject
            expect(json["image"]["characters"]).to eq([])
          end
        end

        context "when an ID is passed" do
          let(:params) do
            {
              id: image.id,
              image: { id: -1, caption: "Stormy weather." },
            }
          end

          include_examples "returns a success HTTP status code"

          it "ignores the ID parameter" do
            expect { subject }.not_to(change { image.reload.id })
          end

          it "returns the image's original ID" do
            original_id = image.id
            subject
            expect(json["image"]["id"]).to eq(original_id)
          end
        end

        context "when a new image file is passed" do
          let(:params) do
            {
              id: image.id,
              image: {
                caption: "Stormy weather.",
                image_file: fixture_file_upload("image.jpg", "image/jpg", true),
              },
            }
          end

          include_examples "returns a success HTTP status code"

          it "ignores the new image" do
            expect { subject }.not_to(
              change { image.reload.image_file.filename.to_s }
            )
          end
        end
      end

      context "when the image doesn't exist" do
        let(:params) { { id: -1 } }

        it "responds with a Not Found HTTP status code" do
          subject
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the image doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No image with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          id: image.id,
          image: { caption: "Stormy weather." },
        }
      end

      it "returns an unauthorized HTTP status code" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
