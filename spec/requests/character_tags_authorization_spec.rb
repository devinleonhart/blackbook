# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Character tags authorization", type: :request do
  it "prevents non-collaborators from creating character tags" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    stranger = create(:user)

    sign_in(stranger)
    expect do
      post character_character_tags_path(character), params: { character_tag: { name: "Elf" } }
    end.not_to change(CharacterTag, :count)

    expect(response).to redirect_to(universes_url)
    expect(flash[:error]).to include("owner or collaborator")
  end

  it "prevents non-collaborators from deleting character tags" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    tag = create(:character_tag, character: character, name: "elf")
    stranger = create(:user)

    sign_in(stranger)
    expect do
      delete character_tag_path(tag)
    end.not_to change(CharacterTag, :count)

    expect(response).to redirect_to(universes_url)
    expect(flash[:error]).to include("owner or collaborator")
  end
end
