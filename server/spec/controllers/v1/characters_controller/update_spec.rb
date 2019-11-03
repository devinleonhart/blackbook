# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharactersController, type: :controller do
  render_views

  let(:original_universe) { create :universe }
  let(:new_universe) { create :universe }

  let(:character) do
    create(
      :character,
      name: "Original Character",
      description: "Original description.",
      universe: original_universe,
    )
  end

  let!(:character_item1) { create(:character_item, character: character) }
  let!(:character_item2) { create(:character_item, character: character) }

  let!(:character_trait1) { create(:character_trait, character: character) }
  let!(:character_trait2) { create(:character_trait, character: character) }

  let(:collaborator) { create :user }

  let(:image) { create :image, caption: "A great pic." }
  let!(:image_tag) { create :image_tag, character: character, image: image }

  before do
    original_universe.collaborators << collaborator
    original_universe.save!
  end

  subject { put(:update, format: :json, params: params) }

  describe "PUT/PATCH update" do
    context "when the user is authenticated as a user with access to the character's original universe" do
      before do
        authenticate(collaborator)
      end

      context "when the character exists" do
        context "when the parameters are valid" do
          let(:params) do
            {
              id: character.id,
              character: {
                id: -1,
                name: "Improved Character",
                description: "Improved description.",
              },
            }
          end

          it "returns a successful HTTP status code" do
            subject
            expect(response).to have_http_status(:success)
          end

          it "doesn't update the character's ID" do
            subject
            expect(character.reload.id).not_to eq(-1)
          end

          it "updates the character's name" do
            subject
            expect(character.reload.name).to eq("Improved Character")
          end

          it "updates the character's description" do
            subject
            expect(character.reload.description).to eq("Improved description.")
          end

          it "returns the character's ID" do
            subject
            expect(json["character"]["id"]).to eq(character.id)
          end

          it "returns the character's new name" do
            subject
            expect(json["character"]["name"]).to eq("Improved Character")
          end

          it "returns the character's new description" do
            subject
            expect(json["character"]["description"]).to(
              eq("Improved description.")
            )
          end

          it "returns a list of the character's items" do
            subject
            expect(json["character"]["items"]).to match_array([
              {
                "id" => character_item1.id,
                "name" => character_item1.item.name,
              },
              {
                "id" => character_item2.id,
                "name" => character_item2.item.name,
              },
            ])
          end

          it "returns a list of the character's traits" do
            subject
            expect(json["character"]["traits"]).to match_array([
              {
                "id" => character_trait1.id,
                "name" => character_trait1.trait.name,
              },
              {
                "id" => character_trait2.id,
                "name" => character_trait2.trait.name,
              },
            ])
          end

          it "returns a list of the images the character is tagged in" do
            subject
            expect(json["character"]["image_tags"].length).to eq(1)
            image_tag_json = json["character"]["image_tags"].first
            expect(image_tag_json["image_tag_id"]).to eq(image_tag.id)
            expect(image_tag_json["image_id"]).to eq(image.id)
            expect(image_tag_json["image_caption"]).to eq("A great pic.")
            expect(image_tag_json["image_url"]).to(
              start_with("/rails/active_storage/blobs/")
            )
          end
        end

        context "when the name parameter isn't valid" do
          let(:params) { { id: character.id, character: { name: "" } } }

          it "returns a Bad Request status" do
            subject
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the character's name" do
            subject
            expect(character.reload.name).to eq("Original Character")
          end

          it "returns an error message for the invalid name" do
            subject
            expect(json["errors"]).to eq(["Name can't be blank"])
          end
        end

        context "when the description parameter isn't valid" do
          let(:params) { { id: character.id, character: { description: "" } } }

          it "returns a Bad Request status" do
            subject
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the character's description" do
            subject
            expect(character.reload.description).to eq("Original description.")
          end

          it "returns an error message for the invalid description" do
            subject
            expect(json["errors"]).to eq(["Description can't be blank"])
          end
        end

        context "when an attempt is made to change the character's universe" do
          let(:params) do
            {
              id: character.id,
              character: {
                universe_id: new_universe.id,
                name: "Improved Character",
              },
            }
          end

          it "returns a successful HTTP status code" do
            subject
            expect(response).to have_http_status(:success)
          end

          it "ignores any attempt to change the character's universe" do
            subject
            expect(character.reload.universe).to eq(original_universe)
          end
        end
      end

      context "when the character doesn't exist" do
        let(:params) { { id: -1 } }

        it "responds with a Not Found HTTP status code" do
          subject
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the character doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No character with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      let(:params) do
        {
          id: character.id,
          character: {
            id: -1,
            name: "Improved Character",
            description: "Improved description.",
          },
        }
      end

      before do
        authenticate(create(:user))
      end

      it "returns a forbidden HTTP status code" do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{original_universe.id} to interact with its characters.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          id: character.id,
          character: {
            id: -1,
            name: "Improved Character",
            description: "Improved description.",
          },
        }
      end

      it "returns an unauthorized HTTP status code" do
        subject
        expect(response).to have_http_status(:unauthorized)
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
