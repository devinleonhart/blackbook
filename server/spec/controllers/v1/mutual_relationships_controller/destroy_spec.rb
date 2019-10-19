# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::MutualRelationshipsController, type: :controller do
  render_views

  let!(:mutual_relationship) do
    create :mutual_relationship, character_universe: universe
  end

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "DELETE destroy" do
    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the MutualRelationship exists" do
        before do
          delete(
            :destroy,
            format: :json,
            params: { id: mutual_relationship.id },
          )
        end

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "deletes the MutualRelationship" do
          expect(MutualRelationship.count).to be(0)
        end

        it "deletes the attached Relationships" do
          expect(Relationship.count).to be(0)
        end
      end

      context "when the MutualRelationship doesn't exist" do
        before { delete(:destroy, format: :json, params: { id: -1 }) }

        it "returns a Not Found Response" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message informing the user the resource doesn't exist" do
          expect(json["errors"]).to eq(
            ["No MutualRelationship with ID -1 exists."]
          )
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      before do
        authenticate(create(:user))
        delete(:destroy, format: :json, params: { id: mutual_relationship.id })
      end

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't delete the MutualRelationship" do
        expect(MutualRelationship.count).to eq(1)
      end

      it "doesn't delete the attached Relationships" do
        expect(Relationship.count).to eq(2)
      end

      it "returns an error message informing the user they don't have access" do
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its relationships.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      before do
        delete(:destroy, format: :json, params: { id: mutual_relationship.id })
      end

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't delete the MutualRelationship" do
        expect(MutualRelationship.count).to eq(1)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
