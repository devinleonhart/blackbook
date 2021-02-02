# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterItemsController, type: :controller do
  render_views

  let(:universe) do
    universe = build(:universe, owner: owner)
    universe.collaborators << collaborator
    universe.save!
    universe
  end
  let(:owner) { create :user }
  let(:not_owner) { create :user }
  let(:collaborator) { create :user }
  let(:character) { create :character, universe: universe }

  describe "POST create" do
    subject { post(:create, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the named item exists" do
        let!(:item) { create :item, name: "Windy Woof" }
        let(:params) do
          {
            character_id: character.id,
            character_item: { item_name: "Windy Woof" },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "creates a new CharacterItem" do
          expect { subject }.to change { CharacterItem.count }.by(1)
        end

        it "sets the new CharacterItem's item to the existing Item" do
          subject
          expect(CharacterItem.first.item_id).to eq(item.id)
        end

        it "returns the new CharacterItem's ID" do
          subject
          expect(json["character_item"]["id"]).to eq(CharacterItem.first.id)
        end

        it "returns the new CharacterItem's item name" do
          subject
          expect(json["character_item"]["name"]).to eq("Windy Woof")
        end
      end

      context "when the named item doesn't exist" do
        let(:params) do
          {
            character_id: character.id,
            character_item: { item_name: "Windy Woof" },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "creates a new Item with the requested name" do
          expect { subject }.to change { Item.count }.by(1)
          expect(Item.last.name).to eq("Windy Woof")
        end

        it "assigns the new Item to the new CharacterItem" do
          subject
          new_item = Item.find_by(name: "Windy Woof")
          expect(CharacterItem.first.item).to eq(new_item)
        end

        it "returns the new CharacterItem's ID" do
          subject
          expect(json["character_item"]["id"]).to eq(CharacterItem.first.id)
        end

        it "returns the new CharacterItem's item name" do
          subject
          expect(json["character_item"]["name"]).to eq("Windy Woof")
        end
      end

      context "when the item name parameter isn't valid" do
        let(:params) do
          {
            character_id: character.id,
            character_item: { item_name: "" },
          }
        end

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the CharacterItem" do
          expect { subject }.not_to change { CharacterItem.count }
        end

        it "returns an error message for the invalid name" do
          subject
          expect(json["errors"]).to eq(["Name can't be blank"])
        end
      end

      context "when the character_id parameter isn't valid" do
        let(:params) do
          {
            character_id: -1,
            character_item: { item_name: "Windy Woof" },
          }
        end

        it { is_expected.to have_http_status(:not_found) }

        it "doesn't create the CharacterItem" do
          expect { subject }.not_to change { CharacterItem.count }
        end

        it "returns an error message for the invalid character ID" do
          subject
          expect(json["errors"]).to eq(["No character with ID -1 exists."])
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      let(:params) do
        {
          character_id: character.id,
          character_item: { item_name: "Windy Woof" },
        }
      end

      before { authenticate(not_owner) }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't create a new CharacterItem" do
        expect { subject }.not_to change { CharacterItem.count }
      end

      it "returns an error message informing the user they don't have access" do
        subject
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
          character_id: -1,
          character_item: { item_name: "Windy Woof" },
        }
      end

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't create a new CharacterItem" do
        expect { subject }.not_to change { CharacterItem.count }
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
