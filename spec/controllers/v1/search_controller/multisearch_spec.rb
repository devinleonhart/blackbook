# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::SearchController, type: :controller do
  render_views

  let(:owner) { create :user }
  let(:collaborator) { create :user }

  let!(:universe1) { create :universe, name: "Milky Way", owner: owner }
  let!(:universe2) { create :universe, name: "Andromeda" }

  before do
    universe1.collaborators << collaborator
    universe1.save!
  end

  describe "GET search" do
    subject { get(:multisearch, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when there is a matching Character model" do
        let!(:character) do
          create(
            :character,
            name: "Arturo",
            description: <<~DESCRIPTION.squish,
              An adventurer and explorer of the far reaches of the Milky Way galaxy.
            DESCRIPTION
            universe: universe1,
          )
        end
        let(:params) { { universe_id: universe1.id, terms: "adven" } }

        it { is_expected.to have_http_status(:success) }

        it "finds matches on the Character model" do
          subject
          expect(json["matches"]).to eq([
            "id" => character.id,
            "name" => character.name,
            "type" => "Character",
            "highlights" => [<<~HIGHLIGHT.squish],
              Arturo An <strong>adventurer</strong> and explorer of the far
              reaches of the Milky Way galaxy
            HIGHLIGHT
          ])
        end
      end

      context "when there is a matching Location model" do
        let!(:location) do
          create(
            :location,
            name: "Vanishing Point Station",
            description: <<~DESCRIPTION.squish,
              A space dock at the edge of known space. A gateway to adventure.
            DESCRIPTION
            universe: universe1,
          )
        end
        let(:params) { { universe_id: universe1.id, terms: "adven" } }

        it { is_expected.to have_http_status(:success) }

        it "finds matches on the Location model" do
          subject
          expect(json["matches"]).to eq([
            "id" => location.id,
            "name" => location.name,
            "type" => "Location",
            "highlights" => [<<~HIGHLIGHT.squish],
              Vanishing Point Station A space dock at the edge of known space.
              A gateway to <strong>adventure</strong>
            HIGHLIGHT
          ])
        end
      end

      context "when there is a matching CharacterItem" do
        let(:character) { create :character, universe: universe1 }
        let(:item) { create :item, name: "Adventurer's Kit" }
        let!(:character_item) do
          create :character_item, character: character, item: item
        end
        let(:params) { { universe_id: universe1.id, terms: "adven" } }

        it { is_expected.to have_http_status(:success) }

        it "returns the attached Character with the Item's name as the highlight" do
          subject
          expect(json["matches"]).to eq([
            "id" => character.id,
            "name" => character.name,
            "type" => "Character",
            "highlights" => ["<strong>Adventurer</strong>"],
          ])
        end
      end

      context "when there is a matching CharacterTrait" do
        let(:character) { create :character, universe: universe1 }
        let(:trait) { create :trait, name: "Adventurous" }
        let!(:character_trait) do
          create :character_trait, character: character, trait: trait
        end
        let(:params) { { universe_id: universe1.id, terms: "adven" } }

        it { is_expected.to have_http_status(:success) }

        it "returns the attached Character with the Trait's name as the highlight" do
          subject
          expect(json["matches"]).to eq([
            "id" => character.id,
            "name" => character.name,
            "type" => "Character",
            "highlights" => ["<strong>Adventurous</strong>"],
          ])
        end
      end

      context "when there are multiple matching models across universes" do
        let!(:location1) do
          create :location, name: "Adventure Station", universe: universe1
        end
        let!(:location2) do
          create :location, name: "Adventure Station", universe: universe2
        end
        let(:params) { { universe_id: universe1.id, terms: "adven" } }

        it { is_expected.to have_http_status(:success) }

        it "only returns matches to models in the requested universe" do
          subject
          matched_model_ids = json["matches"].map { |match| match["id"] }
          expect(matched_model_ids).not_to include(location2.id)
        end
      end

      context "when the search matches both a character and an item the character owns" do
        let(:character) do
          create :character, name: "Adven", universe: universe1
        end
        let(:item) { create :item, name: "Adventurer's Kit" }
        let!(:character_item) do
          create :character_item, character: character, item: item
        end
        let(:params) { { universe_id: universe1.id, terms: "adven" } }

        it { is_expected.to have_http_status(:success) }

        it "only returns the Character once" do
          subject
          expect(json["matches"].length).to eq(1)
          expect(json["matches"].first["id"]).to eq(character.id)
        end

        # this test shows some of the problems with the pg_search gem:
        # 1. it concatenates all the searchable text for a model and then
        # highlights it, so unrelated text will show up in the highlight (e.g.
        # when the name field matches, the start of the description will show
        # up in the returned highlight)
        # 2. it breaks on special characters, so "Adventurer's Kit" returns an
        # unintuitive highlight of "Adventurer"
        it "returns the Character with the highlights combined" do
          subject
          expect(json["matches"].first["highlights"]).to match_array([
            "<strong>Adven</strong> description",
            "<strong>Adventurer</strong>",
          ])
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the universe" do
      before { authenticate(create(:user)) }
      let(:params) { { universe_id: universe1.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating this user can't interact with the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe1.id} to interact with its models.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { universe_id: universe1.id } }

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
