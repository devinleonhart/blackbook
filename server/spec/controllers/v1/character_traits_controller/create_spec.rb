# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterTraitsController, type: :controller do
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

      context "when the named trait exists" do
        let!(:trait) { create :trait, name: "Adventurous" }

        let(:params) do
          {
            universe_id: universe.id,
            character_id: character.id,
            character_trait: { id: -1, trait_name: "Adventurous" },
          }
        end

        before { post(:create, format: :json, params: params) }

        subject(:character_trait) { CharacterTrait.first }
        subject(:character_trait_json) { json["character_trait"] }

        it "returns a successful HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "ignores the id parameter" do
          expect(character_trait.id).not_to eq(-1)
        end

        it "sets the new CharacterTrait's trait to the existing Trait" do
          expect(character_trait.trait_id).to eq(trait.id)
        end

        it "returns the new CharacterTrait's ID" do
          expect(character_trait_json["id"]).to eq(character_trait.id)
        end

        it "returns the new CharacterTrait's trait name" do
          expect(character_trait_json["name"]).to eq("Adventurous")
        end
      end

      context "when the named trait doesn't exist" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character.id,
            character_trait: { id: -1, trait_name: "Adventurous" },
          }
        end

        before { post(:create, format: :json, params: params) }

        subject(:character_trait) { CharacterTrait.first }
        subject(:character_trait_json) { json["character_trait"] }

        it "returns a successful HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "ignores the id parameter" do
          expect(character_trait.id).not_to eq(-1)
        end

        it "creates a new Trait with the requested name" do
          expect(Trait.last.name).to eq("Adventurous")
        end

        it "assigns the new Trait to the new CharacterTrait" do
          new_trait = Trait.find_by(name: "Adventurous")
          expect(character_trait.trait).to eq(new_trait)
        end

        it "returns the new CharacterTrait's ID" do
          expect(character_trait_json["id"]).to eq(character_trait.id)
        end

        it "returns the new character trait's name" do
          expect(character_trait_json["name"]).to eq("Adventurous")
        end
      end

      context "when the trait name parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character.id,
            character_trait: { trait_name: "" },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character_trait) { CharacterTrait.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the CharacterTrait" do
          expect(character_trait).to be_nil
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
            character_trait: { trait_name: "Adventurous" },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character_trait) { CharacterTrait.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:not_found)
        end

        it "doesn't create the CharacterTrait" do
          expect(character_trait).to be_nil
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
            character_trait: { trait_name: "Adventurous" },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:character_trait) { CharacterTrait.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the CharacterTrait" do
          expect(character_trait).to be_nil
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
          character_trait: { trait_name: "Adventurous" },
        }
      end

      before do
        authenticate(not_owner)
        post(:create, format: :json, params: params)
      end

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't create a new CharacterTrait" do
        expect(CharacterTrait.count).to eq(0)
      end

      it "returns an error message informing the user they don't have access" do
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
          universe_id: universe.id,
          character_id: -1,
          character_trait: { trait_name: "Adventurous" },
        }
      end

      before { post(:create, format: :json, params: params) }

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create a new CharacterTrait" do
        expect(CharacterTrait.count).to eq(0)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
