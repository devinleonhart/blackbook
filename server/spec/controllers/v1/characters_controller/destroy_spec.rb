# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharactersController, type: :controller do
  render_views

  let!(:character) { create :character, universe: universe }

  let(:universe) { create :universe, owner: owner }
  let(:owner) { create :user }
  let(:collaborator) { create :user }
  let(:not_owner) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "DELETE delete" do
    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the character exists" do
        before { delete(:destroy, format: :json, params: { id: character.id }) }

        it "returns a success response" do
          expect(response).to have_http_status(:success)
        end

        it "deletes the character" do
          expect(Character.count).to be(0)
        end
      end

      context "when the character doesn't exist" do
        before { delete(:destroy, format: :json, params: { id: -1 }) }

        it "returns a Not Found Response" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      before do
        authenticate(not_owner)
        delete(:destroy, format: :json, params: { id: character.id })
      end

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't delete the Character" do
        expect(Character.count).to eq(1)
      end

      it "returns an error message informing the user they don't have access" do
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      before { delete(:destroy, format: :json, params: { id: character.id }) }

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't delete the Character" do
        expect(Character.count).to eq(1)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
