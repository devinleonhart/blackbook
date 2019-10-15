# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharactersController, type: :controller do
  render_views

  let(:character) do
    create(
      :character,
      name: "Store",
      description: "Good deals here.",
      universe: universe,
    )
  end

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET show" do
    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the character exists" do
        let(:params) do
          {
            universe_id: universe.id,
            id: character.id,
          }
        end

        before { get(:show, format: :json, params: params) }
        subject(:character_json) { json["character"] }

        it "returns the character's ID" do
          expect(character_json["id"]).to eq(character.id)
        end

        it "returns the character's name" do
          expect(character_json["name"]).to eq("Store")
        end

        it "returns the character's description" do
          expect(character_json["description"]).to eq("Good deals here.")
        end
      end

      context "when the character doesn't exist" do
        let(:params) do
          {
            universe_id: universe.id,
            id: -1,
          }
        end

        before { get(:show, format: :json, params: params) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the character doesn't exist" do
          expect(json["errors"]).to eq([
            "No character with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      let(:params) do
        {
          universe_id: universe.id,
          id: character.id,
        }
      end

      before do
        authenticate(create(:user))
        get(:show, format: :json, params: params)

        it "returns a forbidden HTTP status code" do
          expect(response).to have_http_status(:forbidden)
        end

        it "returns an error message indicating only the owner or a collaborator can view the universe" do
          expect(json["errors"]).to(
            eq([<<~MESSAGE.strip])
              You must be an owner or collaborator for the universe with ID
              #{universe.id} to interact with its characters.
            MESSAGE
          )
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          universe_id: universe.id,
          id: character.id,
        }
      end

      before { get(:show, format: :json, params: params) }

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
