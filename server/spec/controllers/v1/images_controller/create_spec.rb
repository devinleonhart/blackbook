# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::ImagesController, type: :controller do
  render_views

  let(:collaborator) { create :user }
  let!(:universe) { create :universe }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "POST create" do
    subject { post(:create, format: :json, params: params) }

    context "when the user has authenticated" do
      before { authenticate(collaborator) }

      context "when the parameters are valid" do
        let(:params) do
          {
            image: {
              caption: "Sunset on a stormy evening.",
              image_file: fixture_file_upload("image.png", "image/png", true),
            },
          }
        end

        include_examples "returns a success HTTP status code"

        it "creates an Image" do
          expect { subject }.to change { Image.count }.from(0).to(1)
        end

        it "sets the new Image's caption" do
          subject
          expect(Image.first.caption).to eq("Sunset on a stormy evening.")
        end

        # TODO: is there a way to verify the image attachment has the image we
        # expect?
        it "saves the image" do
          expect { subject }.to(
            change { ActiveStorage::Blob.count }.from(0).to(1)
          )
        end

        it "returns the new Image's ID" do
          subject
          expect(json["image"]["id"]).to eq(Image.first.id)
        end

        it "returns the new Image's caption" do
          subject
          expect(json["image"]["caption"]).to eq("Sunset on a stormy evening.")
        end

        it "returns the URL for the new Image's image file" do
          subject
          expect(json["image"]["image_url"]).to eq(
            Rails.application.routes.url_helpers.rails_blob_path(
              Image.first.image_file,
              only_path: true,
            )
          )
        end

        it "returns an empty list of associated characters" do
          subject
          expect(json["image"]["characters"]).to eq([])
        end
      end

      context "when an id parameter is passed" do
        let(:params) do
          {
            image: {
              id: -1,
              caption: "Sunset on a stormy evening.",
              image_file: fixture_file_upload("image.png", "image/png", true),
            },
          }
        end

        include_examples "returns a success HTTP status code"

        it "creates an Image" do
          expect { subject }.to change { Image.count }.from(0).to(1)
        end

        it "ignores the ID parameter" do
          subject
          expect(Image.first.id).not_to eq(-1)
        end
      end

      context "when the image data isn't valid" do
        let(:params) do
          {
            image: {
              caption: "Sunset on a stormy evening.",
              # ActiveStorage will treat a nil value as invalid data, rather
              # than missing data
              image_file: nil,
            },
          }
        end

        it "returns a Bad Request status" do
          subject
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the Image" do
          expect { subject }.not_to change { Image.count }.from(0)
        end

        it "doesn't save the image file" do
          expect { subject }.not_to change { ActiveStorage::Blob.count }.from(0)
        end

        it "returns an error message for the invalid image file" do
          subject
          expect(json["errors"]).to eq([<<~ERROR_MESSAGE.squish])
            Image file has invalid data
            (ActiveSupport::MessageVerifier::InvalidSignature)
          ERROR_MESSAGE
        end
      end

      context "when the image data isn't passed" do
        let(:params) do
          {
            image: {
              caption: "Sunset on a stormy evening.",
            },
          }
        end

        it "returns a Bad Request status" do
          subject
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the Image" do
          expect { subject }.not_to change { Image.count }.from(0)
        end

        it "doesn't save the image file" do
          expect { subject }.not_to change { ActiveStorage::Blob.count }.from(0)
        end

        it "returns an error message for the invalid image file" do
          subject
          expect(json["errors"]).to eq([
            "Image file must have an attached file",
          ])
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          image: {
            caption: "Sunset on a stormy evening.",
            image_file: fixture_file_upload("image.png", "image/png", true),
          },
        }
      end

      it "returns an unauthorized HTTP status code" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create the Image" do
        expect { subject }.not_to change { Image.count }.from(0)
      end

      it "doesn't save the image file" do
        expect { subject }.not_to change { ActiveStorage::Blob.count }.from(0)
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
