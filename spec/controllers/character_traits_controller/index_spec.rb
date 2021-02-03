# frozen_string_literal: true

require "rails_helper"

RSpec.describe CharacterTraitsController, type: :controller do
  render_views

  let!(:character_trait1) do
    create :character_trait, trait: trait1, character: character1
  end
  let(:trait1) { create :trait, name: "Adventurous" }
  let!(:character_trait2) do
    create :character_trait, trait: trait2, character: character1
  end
  let(:trait2) { create :trait, name: "Scarred" }
  let!(:character_trait3) do
    create :character_trait, trait: trait3, character: character2
  end
  let(:trait3) { create :trait, name: "Tired" }

  let(:character1) { create :character, universe: universe }
  let(:character2) { create :character, universe: universe }
  let(:universe) do
    universe = build :universe
    universe.collaborators << collaborator
    universe.save!
    universe
  end
  let(:collaborator) { create :user }

  describe "GET index" do
    subject do
      get(
        :index,
        format: :json,
        params: params,
      )
    end

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      let(:params) do
        { character_id: character1.id }
      end

      it "returns the IDs only for CharacterTraits belonging to the given character" do
        subject
        expected_values = [character_trait1.id, character_trait2.id]
        received_values = json.collect do |character_trait|
          character_trait["id"]
        end
        expect(received_values).to match_array(expected_values)
      end

      it "returns the names only for CharacterTraits belonging to the given character" do
        subject
        received_values = json.collect do |character_trait|
          character_trait["name"]
        end
        expect(received_values).to match_array(["Adventurous", "Scarred"])
      end

      it { is_expected.to have_http_status(:success) }
    end

    context "when the user is authenticated as a user who doesn't have access to the universe" do
      before do
        authenticate(create(:user))
        get(
          :index,
          format: :json,
          params: { character_id: character1.id }
        )
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating this user can't interact with the universe" do
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters' traits.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      before do
        get(
          :index,
          format: :json,
          params: { character_id: character1.id },
        )
      end

      it "returns a forbidden HTTP status code" do
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
