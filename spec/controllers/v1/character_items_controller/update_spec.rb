# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterItemsController, type: :controller do
  render_views

  let!(:character_item) do
    create(
      :character_item,
      item: watermelon,
      character: original_character,
    )
  end

  let(:watermelon) { create :item, name: "Watermelon" }

  let(:original_character) { create :character, universe: universe }
  let(:new_character) { create :character, universe: universe }
  let(:universe) do
    universe = build :universe
    universe.collaborators << collaborator
    universe.save!
    universe
  end
  let(:collaborator) { create :user }

  describe "PUT/PATCH update" do
    subject { put(:update, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the character's universe" do
      before { authenticate(collaborator) }

      context "when the CharacterItem exists" do
        context "when an Item exists with the requested name" do
          before { create :item, name: "Half-Eaten Watermelon" }

          let(:params) do
            {
              id: character_item.id,
              character_item: { item_name: "Half-Eaten Watermelon" },
            }
          end

          it { is_expected.to have_http_status(:success) }

          it "doesn't create a new Item" do
            expect { subject }.not_to change { Item.count }
          end

          it "updates the CharacterItem's name" do
            subject
            expect(character_item.reload.item.name).to(
              eq("Half-Eaten Watermelon")
            )
          end

          it "returns the CharacterItem's ID" do
            subject
            expect(json["character_item"]["id"]).to eq(character_item.id)
          end

          it "returns the CharacterItem's new item name" do
            subject
            expect(json["character_item"]["name"]).to(
              eq("Half-Eaten Watermelon")
            )
          end
        end

        context "when the new item name doesn't exist as an Item" do
          let(:params) do
            {
              id: character_item.id,
              character_item: { item_name: "Half-Eaten Watermelon" },
            }
          end

          it { is_expected.to have_http_status(:success) }

          it "creates the new Item" do
            expect { subject }.to change { Item.count }.by(1)
            expect(Item.last.name).to eq("Half-Eaten Watermelon")
          end

          it "updates the CharacterItem's name" do
            subject
            expect(character_item.reload.item.name).to(
              eq("Half-Eaten Watermelon")
            )
          end

          it "returns the CharacterItem's ID" do
            subject
            expect(json["character_item"]["id"]).to eq(character_item.id)
          end

          it "returns the CharacterItem's new item name" do
            subject
            expect(json["character_item"]["name"]).to(
              eq("Half-Eaten Watermelon")
            )
          end
        end

        context "when the name parameter isn't valid" do
          let(:params) do
            { id: character_item.id, character_item: { item_name: "" } }
          end

          it { is_expected.to have_http_status(:bad_request) }

          it "doesn't update the CharacterItem's name" do
            expect { subject }.not_to change { character_item.reload.item_id }
          end

          it "returns an error message for the invalid name" do
            subject
            expect(json["errors"]).to eq(["Name can't be blank"])
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

          it { is_expected.to have_http_status(:success) }

          it "ignores any attempt to change the CharacterItem's associated character" do
            expect { subject }.not_to change {
              character_item.reload.character_id
            }
          end
        end
      end

      context "when the CharacterItem doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      let(:params) do
        {
          id: character_item.id,
          character_item: { item_name: "Half-Eaten Watermelon" },
        }
      end

      before { authenticate(create(:user)) }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
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
          id: character_item.id,
          character_item: { item_name: "Half-Eaten Watermelon" },
        }
      end

      it { is_expected.to have_http_status(:unauthorized) }

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
