# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Character tags authorization", type: :request do
  let(:character) { create(:character, universe: create(:universe, owner: create(:user))) }
  let(:stranger) { create(:user) }

  before { sign_in(stranger) }

  describe "POST create" do
    it "prevents a non-collaborator from creating character tags" do
      expect do
        post character_character_tags_path(character), params: { character_tag: { name: "Elf" } }
      end.not_to change(CharacterTag, :count)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to include("owner or collaborator")
    end
  end

  describe "DELETE destroy" do
    it "prevents a non-collaborator from deleting character tags" do
      tag = create(:character_tag, character: character, name: "elf")

      expect do
        delete character_tag_path(tag)
      end.not_to change(CharacterTag, :count)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to include("owner or collaborator")
    end
  end
end
