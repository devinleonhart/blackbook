# frozen_string_literal: true

require "rails_helper"

RSpec.describe CharacterTraitsController, type: :controller do
  render_views

  let(:character_trait) do
    create(:character_trait, trait: trait, character: character)
  end
  let(:trait) { create :trait, name: "Adventurous" }

  let(:character) { create :character, universe: universe }
  let(:universe) do
    universe = build :universe
    universe.collaborators << collaborator
    universe.save!
    universe
  end
  let(:collaborator) { create :user }

  describe "GET show" do
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the CharacterTrait exists" do
        let(:params) { { id: character_trait.id } }

        it "returns the CharacterTrait's ID" do
          subject
          expect(json["character_trait"]["id"]).to eq(character_trait.id)
        end

        it "returns the CharacterTrait's trait name" do
          subject
          expect(json["character_trait"]["name"]).to eq("Adventurous")
        end
      end

      context "when the CharacterTrait doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message indicating the CharacterTrait doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No CharacterTrait with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before { authenticate(create(:user)) }

      let(:params) { { id: character_trait.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
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
      let(:params) { { id: character_trait.id } }

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
