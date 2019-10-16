# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterItemsController, type: :controller do
  render_views

  let(:character_item) do
    create(
      :character_item,
      item: watermelon,
      character: original_character,
    )
  end

  let(:watermelon) { create :item, name: "Watermelon" }

  let(:original_character) { create :character, universe: universe }
  let(:new_character) { create :character, universe: universe }
  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "PUT/PATCH update" do
    context "when the user is authenticated as a user with access to the character's universe" do
      before do
        authenticate(collaborator)
      end

      context "when the CharacterItem exists" do
        context "when an Item exists with the requested name" do
          let!(:new_item) { create :item, name: "Half-Eaten Watermelon" }

          let(:params) do
            {
              id: character_item.id,
              character_item: { item_name: "Half-Eaten Watermelon" },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_item_json) { json["character_item"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't create a new Item" do
            expect(Item.count).to eq(2)
          end

          it "updates the CharacterItem's name" do
            expect(character_item.reload.item.name).to(
              eq("Half-Eaten Watermelon")
            )
          end

          it "returns the CharacterItem's ID" do
            expect(character_item_json["id"]).to eq(character_item.id)
          end

          it "returns the CharacterItem's new item name" do
            expect(character_item_json["name"]).to eq("Half-Eaten Watermelon")
          end
        end

        context "when the new item name doesn't exist as an Item" do
          let(:params) do
            {
              id: character_item.id,
              character_item: { item_name: "Half-Eaten Watermelon" },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_item_json) { json["character_item"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "creates a new Item" do
            expect(Item.last.name).to eq("Half-Eaten Watermelon")
          end

          it "updates the CharacterItem's name" do
            expect(character_item.reload.item.name).to(
              eq("Half-Eaten Watermelon")
            )
          end

          it "returns the CharacterItem's ID" do
            expect(character_item_json["id"]).to eq(character_item.id)
          end

          it "returns the CharacterItem's new item name" do
            expect(character_item_json["name"]).to eq("Half-Eaten Watermelon")
          end
        end

        context "when an attempt is made to change the CharacterItem's ID" do
          let(:params) do
            {
              id: character_item.id,
              character_item: {
                id: -1,
                item_name: "Half-Eaten Watermelon",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_item_json) { json["character_item"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't update the CharacterItem's ID" do
            expect(character_item.reload.id).not_to eq(-1)
          end

          it "returns the CharacterItem's original ID" do
            expect(character_item_json["id"]).to eq(character_item.id)
          end
        end

        context "when the name parameter isn't valid" do
          let(:params) do
            { id: character_item.id, character_item: { item_name: "" } }
          end

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the CharacterItem's name" do
            expect(character_item.reload.item.name).to eq("Watermelon")
          end

          it "returns an error message for the invalid name" do
            expect(errors).to eq(["Name can't be blank"])
          end
        end

        context "when an attempt is made to change the CharacterItem's associated character" do
          let(:params) do
            {
              id: character_item.id,
              character_item: {
                character_id: new_character.id,
                item_name: "Half-Eaten Watermelon",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_item_json) { json["character_item"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "ignores any attempt to change the CharacterItem's associated character" do
            expect(character_item.reload.character).to eq(original_character)
          end
        end
      end

      context "when the CharacterItem doesn't exist" do
        before { put(:update, format: :json, params: { id: -1 }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      let(:params) do
        {
          id: character_item.id,
          character_item: { item_name: "Half-Eaten Watermelon" },
        }
      end

      before do
        authenticate(create(:user))
        put(:update, format: :json, params: params)
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
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
          id: character_item.id,
          character_item: { item_name: "Half-Eaten Watermelon" },
        }
      end

      before { put(:update, format: :json, params: params) }

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
