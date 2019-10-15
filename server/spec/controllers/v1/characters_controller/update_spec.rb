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

  let(:collaborator) { create :user }

  before do
    original_universe.collaborators << collaborator
    original_universe.save!
  end

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
                universe_id: new_universe.id,
                name: "Improved Character",
                description: "Improved description.",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:character_json) { json["character"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't update the character's ID" do
            expect(character.reload.id).not_to eq(-1)
          end

          it "updates the character's name" do
            expect(character.reload.name).to eq("Improved Character")
          end

          it "ignores any attempt to change the character's universe" do
            expect(character.reload.universe).to eq(original_universe)
          end

          it "updates the character's description" do
            expect(character.reload.description).to eq("Improved description.")
          end

          it "returns the character's ID" do
            expect(character_json["id"]).to eq(character.id)
          end

          it "returns the character's new name" do
            expect(character_json["name"]).to eq("Improved Character")
          end

          it "returns the character's new description" do
            expect(character_json["description"]).to eq("Improved description.")
          end
        end

        context "when the name parameter isn't valid" do
          let(:params) { { id: character.id, character: { name: "" } } }

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the character's name" do
            expect(character.reload.name).to eq("Original Character")
          end

          it "returns an error message for the invalid name" do
            expect(errors).to eq(["Name can't be blank"])
          end
        end

        context "when the description parameter isn't valid" do
          let(:params) { { id: character.id, character: { description: "" } } }

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the character's description" do
            expect(character.reload.description).to eq("Original description.")
          end

          it "returns an error message for the invalid description" do
            expect(errors).to eq(["Description can't be blank"])
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

          before { put(:update, format: :json, params: params) }
          subject(:character_json) { json["character"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "ignores any attempt to change the character's universe" do
            expect(character.reload.universe).to eq(original_universe)
          end
        end
      end

      context "when the character doesn't exist" do
        before { put(:update, format: :json, params: { id: -1 }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
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
        put(:update, format: :json, params: params)
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
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
