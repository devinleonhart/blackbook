# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharactersController, type: :controller do
  render_views

  let(:universe) { create :universe, owner: owner }
  let(:owner) { create :user }
  let(:not_owner) { create :user }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "POST create" do
    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the parameters are valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character: {
              id: -1,
              name: "Home",
              description: "Is where the heart is.",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character) { Character.first }
        subject(:character_json) { json["character"] }

        it "returns a successful HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "ignores the id parameter" do
          expect(character.id).not_to eq(-1)
        end

        it "sets the new character's name" do
          expect(character.name).to eq("Home")
        end

        it "sets the new character's description" do
          expect(character.description).to eq("Is where the heart is.")
        end

        it "returns the new character's ID" do
          expect(character_json["id"]).to eq(character.id)
        end

        it "returns the new character's name" do
          expect(character_json["name"]).to eq("Home")
        end

        it "returns the new character's description" do
          expect(character_json["description"]).to eq("Is where the heart is.")
        end
      end

      context "when the name parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character: {
              name: "",
              description: "Is where the heart is.",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character) { Character.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the character" do
          expect(character).to be_nil
        end

        it "returns an error message for the invalid name" do
          expect(errors).to eq(["Name can't be blank"])
        end
      end

      context "when the description parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character: {
              name: "Home",
              description: "",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character) { Character.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the character" do
          expect(character).to be_nil
        end

        it "returns an error message for the invalid name" do
          expect(errors).to eq(["Description can't be blank"])
        end
      end

      context "when the universe_id parameter isn't valid" do
        let(:params) do
          {
            universe_id: -1,
            character: {
              name: "Home",
              description: "Is where the heart is.",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character) { Character.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:not_found)
        end

        it "doesn't create the character" do
          expect(character).to be_nil
        end

        it "returns an error message for the invalid universe ID" do
          expect(errors).to eq(["No universe with ID -1 exists."])
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      let(:params) do
        {
          universe_id: universe.id,
          character: {
            id: -1,
            name: "Home",
            description: "Is where the heart is.",
          },
        }
      end

      before do
        authenticate(not_owner)
        post(:create, format: :json, params: params)
      end

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't create a new Character" do
        expect(Character.count).to eq(0)
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
      let(:params) do
        {
          universe_id: universe.id,
          character: {
            id: -1,
            name: "Home",
            description: "Is where the heart is.",
          },
        }
      end

      before { post(:create, format: :json, params: params) }

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create a new Character" do
        expect(Character.count).to eq(0)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
