# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::ImageTagsController, type: :controller do
  render_views

  let!(:image_tag) { create :image_tag, character: character }
  let(:character) { create :character, universe: universe }
  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "DELETE destroy" do
    subject { delete(:destroy, format: :json, params: params) }

    context "when the user is authenticated" do
      before { authenticate(collaborator) }

      context "when the image_tag exists" do
        let(:params) { { id: image_tag.id } }

        it { is_expected.to have_http_status(:success) }

        it "deletes the image_tag" do
          expect { subject }.to change { ImageTag.count }.by(-1)
        end
      end

      context "when the image_tag doesn't exist" do
        let(:params) { { id: -1 } }

        it "returns a Not Found Response" do
          subject
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message informing the user the resource doesn't exist" do
          subject
          expect(json["errors"]).to eq(["No image_tag with ID -1 exists."])
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      before do
        authenticate(create(:user))
      end

      let(:params) { { id: image_tag.id } }

      it "returns an unauthorized HTTP status code" do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't delete the ImageTag" do
        expect { subject }.not_to change { ImageTag.count }
      end

      it "returns an error message informing the user they don't have access" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters' images.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: image_tag.id } }

      it "returns an unauthorized HTTP status code" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't destroy the image_tag" do
        expect { subject }.not_to change { ImageTag.count }
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
