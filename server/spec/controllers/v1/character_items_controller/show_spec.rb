# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterItemsController, type: :controller do
  render_views

  let(:character_item) do
    create(:character_item, item: item, character: character)
  end
  let(:item) { create :item, name: "Cookies" }

  let(:character) { create :character, universe: universe }
  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET show" do
    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the CharacterItem exists" do
        before { get(:show, format: :json, params: { id: character_item.id }) }
        subject(:character_item_json) { json["character_item"] }

        it "returns the CharacterItem's ID" do
          expect(character_item_json["id"]).to eq(character_item.id)
        end

        it "returns the CharacterItem's item name" do
          expect(character_item_json["name"]).to eq("Cookies")
        end
      end

      context "when the CharacterItem doesn't exist" do
        before { get(:show, format: :json, params: { id: -1 }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the CharacterItem doesn't exist" do
          expect(json["errors"]).to eq([
            "No CharacterItem with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before do
        authenticate(create(:user))
        get(:show, format: :json, params: { id: character_item.id })

        it "returns a forbidden HTTP status code" do
          expect(response).to have_http_status(:forbidden)
        end

        it "returns an error message indicating only the owner or a collaborator can view the universe" do
          expect(json["errors"]).to(
            eq([<<~MESSAGE.strip])
              You must be an owner or collaborator for the universe with ID
              #{universe.id} to interact with its characters' items.
            MESSAGE
          )
        end
      end
    end

    context "when the user isn't authenticated" do
      before { get(:show, format: :json, params: { id: character_item.id }) }

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
