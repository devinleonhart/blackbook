# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Characters", type: :request do
  include_context "with a signed-in owner"

  let(:character) { create(:character, universe: universe, name: "Aria") }

  describe "GET show" do
    it "renders the character for a viewer with access" do
      get character_path(character)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(character.name)
    end

    it "offers universe tags the character does not already have" do
      other = create(:character, universe: universe)
      create(:character_tag, character: character, name: "hero")
      create(:character_tag, character: other, name: "villain")

      get character_path(character)

      expect(response.body).to include("villain") # available to add from the universe
    end

    it "redirects with a flash when the character does not exist" do
      get character_path(missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end

    it "redirects when the universe is not visible to the user" do
      other = create(:character, universe: create(:universe, owner: create(:user)))

      get character_path(other)

      expect(response).to redirect_to(universes_url)
    end
  end

  describe "GET new" do
    it "renders the new-character form" do
      get new_universe_character_path(universe)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET edit" do
    it "renders the edit form for an accessible character" do
      get edit_character_path(character)

      expect(response).to have_http_status(:ok)
    end

    it "redirects with a flash when the character does not exist" do
      get edit_character_path(missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end

  describe "POST create" do
    context "with valid params" do
      it "creates the character and redirects to it" do
        expect do
          post universe_characters_path(universe), params: { character: { name: "New Char" } }
        end.to change(Character, :count).by(1)

        expect(response).to redirect_to(character_url(Character.order(:id).last))
        expect(flash[:success]).to eq("Character created!")
      end
    end

    context "with invalid params" do
      it "does not create and redirects back to new with a flash" do
        expect do
          post universe_characters_path(universe), params: { character: { name: "" } }
        end.not_to change(Character, :count)

        expect(response).to redirect_to(new_universe_character_url(universe))
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "PATCH update" do
    context "with valid params" do
      it "updates and redirects to the character" do
        patch character_path(character), params: { character: { name: "Renamed" } }

        expect(response).to redirect_to(character_url(character))
        expect(character.reload.name).to eq("Renamed")
        expect(flash[:success]).to eq("Character updated!")
      end
    end

    context "with invalid params" do
      it "does not update and redirects back to edit with a flash" do
        patch character_path(character), params: { character: { name: "" } }

        expect(response).to redirect_to(edit_character_url(character))
        expect(character.reload.name).to eq("Aria")
        expect(flash[:error]).to be_present
      end
    end

    it "redirects with a flash when the character does not exist" do
      patch character_path(missing_id), params: { character: { name: "x" } }

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end

  describe "DELETE destroy" do
    it "destroys the character and redirects to the universe" do
      character # ensure it exists before the count assertion

      expect do
        delete character_path(character)
      end.to change(Character, :count).by(-1)

      expect(response).to redirect_to(universe_url(universe))
      expect(flash[:success]).to eq("Character deleted!")
    end
  end

  describe "authorization" do
    let(:stranger) { create(:user) }

    before { sign_in(stranger) }

    it "redirects a stranger away from a character they cannot access" do
      get character_path(character)

      expect(response).to redirect_to(universes_url)
    end

    it "prevents a stranger from creating a character in an inaccessible universe" do
      expect do
        post universe_characters_path(universe), params: { character: { name: "Sneaky" } }
      end.not_to change(Character, :count)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end

    it "prevents a stranger from opening the new-character form" do
      get new_universe_character_path(universe)

      expect(response).to redirect_to(universes_url)
    end
  end
end
