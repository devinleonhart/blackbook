# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterItemsController, type: :controller do
  render_views

  let(:universe) { create :universe, owner: owner }
  let(:owner) { create :user }
  let(:not_owner) { create :user }
  let(:collaborator) { create :user }
  let(:character) { create :character, universe: universe }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "POST create" do
    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the named item exists" do
        let!(:item) { create :item, name: "Windy Woof" }

        let(:params) do
          {
            universe_id: universe.id,
            character_id: character.id,
            character_item: { id: -1, item_name: "Windy Woof" },
          }
        end

        before { post(:create, format: :json, params: params) }

        subject(:character_item) { CharacterItem.first }
        subject(:character_item_json) { json["character_item"] }

        it "returns a successful HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "ignores the id parameter" do
          expect(character_item.id).not_to eq(-1)
        end

        it "sets the new CharacterItem's item to the existing Item" do
          expect(character_item.item_id).to eq(item.id)
        end

        it "returns the new CharacterItem's ID" do
          expect(character_item_json["id"]).to eq(character_item.id)
        end

        it "returns the new CharacterItem's item name" do
          expect(character_item_json["name"]).to eq("Windy Woof")
        end
      end

      context "when the named item doesn't exist" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character.id,
            character_item: { id: -1, item_name: "Windy Woof" },
          }
        end

        before { post(:create, format: :json, params: params) }

        subject(:character_item) { CharacterItem.first }
        subject(:character_item_json) { json["character_item"] }

        it "returns a successful HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "ignores the id parameter" do
          expect(character_item.id).not_to eq(-1)
        end

        it "creates a new Item with the requested name" do
          expect(Item.last.name).to eq("Windy Woof")
        end

        it "assigns the new Item to the new CharacterItem" do
          new_item = Item.find_by(name: "Windy Woof")
          expect(character_item.item).to eq(new_item)
        end

        it "returns the new CharacterItem's ID" do
          expect(character_item_json["id"]).to eq(character_item.id)
        end

        it "returns the new CharacterItem's item name" do
          expect(character_item_json["name"]).to eq("Windy Woof")
        end
      end

      context "when the item name parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character.id,
            character_item: { item_name: "" },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character_item) { CharacterItem.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the CharacterItem" do
          expect(character_item).to be_nil
        end

        it "returns an error message for the invalid name" do
          expect(errors).to eq(["Name can't be blank"])
        end
      end

      context "when the universe_id parameter isn't valid" do
        let(:params) do
          {
            universe_id: -1,
            character_id: character.id,
            character_item: { item_name: "Windy Woof" },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character_item) { CharacterItem.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:not_found)
        end

        it "doesn't create the CharacterItem" do
          expect(character_item).to be_nil
        end

        it "returns an error message for the invalid universe ID" do
          expect(errors).to eq(["No universe with ID -1 exists."])
        end
      end

      context "when the character_id parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: -1,
            character_item: { item_name: "Windy Woof" },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character_item) { CharacterItem.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the CharacterItem" do
          expect(character_item).to be_nil
        end

        it "returns an error message for the invalid character ID" do
          expect(errors).to eq(["Character must exist"])
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      let(:params) do
        {
          universe_id: universe.id,
          character_id: -1,
          character_item: { item_name: "Windy Woof" },
        }
      end

      before do
        authenticate(not_owner)
        post(:create, format: :json, params: params)
      end

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't create a new CharacterItem" do
        expect(CharacterItem.count).to eq(0)
      end

      it "returns an error message informing the user they don't have access" do
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters' items.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          universe_id: universe.id,
          character_id: -1,
          character_item: { item_name: "Windy Woof" },
        }
      end

      before { post(:create, format: :json, params: params) }

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create a new CharacterItem" do
        expect(CharacterItem.count).to eq(0)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
