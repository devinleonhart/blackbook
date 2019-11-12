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
    subject { post(:create, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the named trait exists" do
        let!(:trait) { create :trait, name: "Adventurous" }

        let(:params) do
          {
            universe_id: universe.id,
            character_id: character.id,
            character_trait: { trait_name: "Adventurous" },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "sets the new CharacterTrait's trait to the existing Trait" do
          subject
          expect(CharacterTrait.first.trait_id).to eq(trait.id)
        end

        it "returns the new CharacterTrait's ID" do
          subject
          expect(json["character_trait"]["id"]).to eq(CharacterTrait.first.id)
        end

        it "returns the new CharacterTrait's trait name" do
          subject
          expect(json["character_trait"]["name"]).to eq("Adventurous")
        end
      end

      context "when the named trait doesn't exist" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character.id,
            character_trait: { trait_name: "Adventurous" },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "creates a new Trait with the requested name" do
          expect { subject }.to change { Trait.count }.by(1)
          expect(Trait.last.name).to eq("Adventurous")
        end

        it "assigns the new Trait to the new CharacterTrait" do
          subject
          new_trait = Trait.find_by(name: "Adventurous")
          expect(CharacterTrait.first.trait).to eq(new_trait)
        end

        it "returns the new CharacterTrait's ID" do
          subject
          expect(json["character_trait"]["id"]).to eq(CharacterTrait.first.id)
        end

        it "returns the new character trait's name" do
          subject
          expect(json["character_trait"]["name"]).to eq("Adventurous")
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

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the CharacterTrait" do
          expect { subject }.not_to change { CharacterTrait.count }
        end

        it "returns an error message for the invalid name" do
          subject
          expect(json["errors"]).to eq(["Name can't be blank"])
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

        it { is_expected.to have_http_status(:not_found) }

        it "doesn't create the CharacterTrait" do
          expect { subject }.not_to change { CharacterTrait.count }
        end

        it "returns an error message for the invalid universe ID" do
          subject
          expect(json["errors"]).to eq(["No universe with ID -1 exists."])
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

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the CharacterTrait" do
          expect { subject }.not_to change { CharacterTrait.count }
        end

        it "returns an error message for the invalid character ID" do
          subject
          expect(json["errors"]).to eq(["Character must exist"])
        end
      end

      context "when the given character isn't in the given universe" do
        let(:non_universe_character) { create :character }

        let(:params) do
          { universe_id: universe.id, character_id: non_universe_character.id }
        end

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create a new CharacterTrait" do
          expect { subject }.not_to change { CharacterTrait.count }
        end

        it "returns an error message for the character not belonging to the universe" do
          subject
          expect(json["errors"]).to eq([<<~ERROR_MESSAGE.squish])
            Character with ID #{non_universe_character.id} does not belong to
            Universe #{universe.id}.
          ERROR_MESSAGE
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      let(:params) do
        {
          universe_id: universe.id,
          character_id: character.id,
          character_trait: { trait_name: "Adventurous" },
        }
      end

      before { authenticate(not_owner) }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't create a new CharacterTrait" do
        expect { subject }.not_to change { CharacterTrait.count }
      end

      it "returns an error message informing the user they don't have access" do
        subject
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
          character_id: character.id,
          character_trait: { trait_name: "Adventurous" },
        }
      end

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't create a new CharacterTrait" do
        expect { subject }.not_to change { CharacterTrait.count }
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
