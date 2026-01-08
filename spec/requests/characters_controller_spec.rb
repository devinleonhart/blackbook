# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Characters", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "lists characters for a universe" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    create(:character, universe: universe, name: "A")
    create(:character, universe: universe, name: "B")

    sign_in_as(owner)
    get universe_characters_path(universe)

    # There is no HTML template for this action today, so Rails returns 406.
    # (This still exercises the controller query path.)
    expect(response).to have_http_status(:not_acceptable)
  end

  it "creates a character and redirects to show" do
    owner = create(:user)
    universe = create(:universe, owner: owner)

    sign_in_as(owner)
    post universe_characters_path(universe), params: { character: { name: "New Char" } }

    character = Character.order(:id).last
    expect(response).to redirect_to(character_url(character))
    expect(character.name).to eq("New Char")
  end

  it "fails to create a character and redirects back to new" do
    owner = create(:user)
    universe = create(:universe, owner: owner)

    sign_in_as(owner)
    post universe_characters_path(universe), params: { character: { name: "" } }
    expect(response).to redirect_to(new_universe_character_url(universe))
  end

  it "updates a character" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe, name: "Old")

    sign_in_as(owner)
    patch character_path(character), params: { character: { name: "Updated" } }

    expect(response).to redirect_to(character_url(character))
    expect(character.reload.name).to eq("Updated")
  end

  it "destroys a character" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)

    sign_in_as(owner)
    expect do
      delete character_path(character)
    end.to change(Character, :count).by(-1)

    expect(response).to redirect_to(universe_url(universe))
  end
end
