# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::ImageTagsController, type: :controller do
  render_views

  let!(:image_tag) { create :image_tag, character: character }

  let(:collaborator) { create :user }
  let!(:universe) { create :universe }

  let(:character) { create :character, universe: universe }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET show" do
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated" do
      before { authenticate(collaborator) }

      context "when the image_tag exists" do
        let(:params) { { id: image_tag.id } }

        include_examples "returns a success HTTP status code"

        it "returns the image_tag's ID" do
          subject
          expect(json["image_tag"]["id"]).to eq(image_tag.id)
        end

        it "returns information on the tagged character" do
          subject
          expect(json["image_tag"]["character"]).to eq(
            "id" => image_tag.character.id,
            "name" => image_tag.character.name,
          )
        end

        it "returns information on the tagged image" do
          subject
          expect(json["image_tag"]["image"]["id"]).to eq(image_tag.image.id)
          expect(json["image_tag"]["image"]["url"]).to(
            start_with("/rails/active_storage/blobs/")
          )
        end
      end

      context "when the image_tag doesn't exist" do
        let(:params) { { id: -1 } }

        it "responds with a Not Found HTTP status code" do
          subject
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the image_tag doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No image_tag with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: image_tag.id } }

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
