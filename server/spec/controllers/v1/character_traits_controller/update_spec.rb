# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterTraitsController, type: :controller do
  render_views

  let(:character_trait) do
    create(
      :character_trait,
      trait: trait,
      character: original_character,
    )
  end

  let(:trait) { create :trait, name: "Adventurous" }

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

      context "when the character trait exists" do
        context "when an Trait exists with the requested name" do
          let!(:new_trait) { create :trait, name: "Tired" }

          let(:params) do
            {
              id: character_trait.id,
              character_trait: { trait_name: "Tired" },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_trait_json) { json["character_trait"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't create a new Trait" do
            expect(Trait.count).to eq(2)
          end

          it "updates the character trait's name" do
            expect(character_trait.reload.trait.name).to(
              eq("Tired")
            )
          end

          it "returns the character trait's ID" do
            expect(character_trait_json["id"]).to eq(character_trait.id)
          end

          it "returns the character trait's new trait name" do
            expect(character_trait_json["name"]).to eq("Tired")
          end
        end

        context "when the new trait name doesn't exist as an Trait" do
          let(:params) do
            {
              id: character_trait.id,
              character_trait: { trait_name: "Tired" },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_trait_json) { json["character_trait"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "creates a new Trait" do
            expect(Trait.last.name).to eq("Tired")
          end

          it "updates the character trait's name" do
            expect(character_trait.reload.trait.name).to(
              eq("Tired")
            )
          end

          it "returns the character trait's ID" do
            expect(character_trait_json["id"]).to eq(character_trait.id)
          end

          it "returns the character trait's new trait name" do
            expect(character_trait_json["name"]).to eq("Tired")
          end
        end

        context "when an attempt is made to change the character trait's ID" do
          let(:params) do
            {
              id: character_trait.id,
              character_trait: {
                id: -1,
                trait_name: "Tired",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_trait_json) { json["character_trait"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't update the character trait's ID" do
            expect(character_trait.reload.id).not_to eq(-1)
          end

          it "returns the character trait's original ID" do
            expect(character_trait_json["id"]).to eq(character_trait.id)
          end
        end

        context "when the name parameter isn't valid" do
          let(:params) do
            { id: character_trait.id, character_trait: { trait_name: "" } }
          end

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the character trait's name" do
            expect(character_trait.reload.trait.name).to eq("Adventurous")
          end

          it "returns an error message for the invalid name" do
            expect(errors).to eq(["Name can't be blank"])
          end
        end

        context "when an attempt is made to change the character trait's associated character" do
          let(:params) do
            {
              id: character_trait.id,
              character_trait: {
                character_id: new_character.id,
                trait_name: "Tired",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_trait_json) { json["character_trait"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "ignores any attempt to change the character trait's associated character" do
            expect(character_trait.reload.character).to eq(original_character)
          end
        end
      end

      context "when the character trait doesn't exist" do
        before { put(:update, format: :json, params: { id: -1 }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      let(:params) do
        {
          id: character_trait.id,
          character_trait: { trait_name: "Tired" },
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
            #{universe.id} to interact with its characters' traits.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          id: character_trait.id,
          character_trait: { trait_name: "Tired" },
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
