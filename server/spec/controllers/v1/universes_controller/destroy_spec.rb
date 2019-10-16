# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let!(:universe) { create :universe, owner: owner }

  let(:owner) { create :user }
  let(:collaborator) { create :user }
  let(:not_owner) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "DELETE destroy" do
    context "when the user is authenticated as the universe's owner" do
      before { authenticate(owner) }

      context "when the universe is available" do
        before { delete(:destroy, format: :json, params: { id: universe.id }) }

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "soft deletes the universe" do
          expect(universe.reload.discarded?).to be(true)
        end
      end

      context "when the universe is already deleted" do
        before do
          universe.discard!
        end

        before { delete(:destroy, format: :json, params: { id: universe.id }) }

        it "is idempotent" do
          expect(response).to have_http_status(:success)
          expect(universe.reload.discarded?).to be(true)
        end
      end

      context "when the universe doesn't exist" do
        before { delete(:destroy, format: :json, params: { id: -1 }) }

        it "returns a Not Found Response" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message informing the user the resource doesn't exist" do
          expect(json["errors"]).to eq(["No universe with ID -1 exists."])
        end
      end
    end

    context "when the user is signed in as a collaborator" do
      before do
        authenticate(collaborator)
        delete(:destroy, format: :json, params: { id: universe.id })
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't destroy the universe" do
        expect(Universe.count).to eq(1)
      end
    end

    context "when the user is signed in as a user who isn't the universe's owner" do
      before do
        authenticate(not_owner)
        delete(:destroy, format: :json, params: { id: universe.id })
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't destroy the universe" do
        expect(Universe.count).to eq(1)
      end

      it "doesn't soft delete the universe" do
        expect(Universe.kept.count).to eq(1)
      end

      it "returns an error message indicating only the owner can delete a universe" do
        expect(json["errors"]).to(
          eq(["A universe can only be deleted by its owner."])
        )
      end
    end

    context "when the user is signed in as a user who isn't the universe's owner" do
      before do
        authenticate(not_owner)
        delete(:destroy, format: :json, params: { id: universe.id })
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't destroy the universe" do
        expect(Universe.count).to eq(1)
      end

      it "doesn't soft delete the universe" do
        expect(Universe.kept.count).to eq(1)
      end

      it "returns an error message indicating only the owner can delete a universe" do
        expect(json["errors"]).to(
          eq(["A universe can only be deleted by its owner."])
        )
      end
    end

    context "when the user isn't authenticated" do
      before { delete(:destroy, format: :json, params: { id: universe.id }) }

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't destroy the universe" do
        expect(Universe.count).to eq(1)
      end

      it "doesn't soft delete the universe" do
        expect(Universe.kept.count).to eq(1)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
