# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImagesController, type: :controller do
  render_views

  let!(:image) { create :image, caption: "A great pic." }

  let(:collaborator) { create :user }
  let!(:universe) { create :universe }

  let!(:character1) { create :character, universe: universe }
  let!(:character2) { create :character }

  before do
    universe.collaborators << collaborator
    universe.save!

    image.characters = [character1, character2]
    image.save!
  end

  describe "GET show" do
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated" do
      before { authenticate(collaborator) }

      context "when the image exists" do
        let(:params) { { id: image.id } }

        it { is_expected.to have_http_status(:success) }

        it "returns the image's ID" do
          subject
          expect(json["image"]["id"]).to eq(image.id)
        end

        it "returns the image's caption" do
          subject
          expect(json["image"]["caption"]).to eq("A great pic.")
        end

        it "returns the image file's URL" do
          subject
          expect(json["image"]["image_url"]).to eq(
            Rails.application.routes.url_helpers.rails_blob_path(
              image.image_file,
              only_path: true,
            )
          )
        end

        it "returns a list of the characters tagged in the image that are visible to the current user" do
          subject
          expect(json["image"]["characters"]).to eq([
            {
              "id" => character1.id,
              "name" => character1.name,
            },
          ])
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
      let(:params) { { id: image.id } }

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
