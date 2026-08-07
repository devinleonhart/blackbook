# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Character tags authorization", type: :request do
  let(:character) { create(:character, universe: create(:universe, owner: create(:user))) }
  let(:stranger) { create(:user) }

  before { sign_in(stranger) }

  describe "POST create" do
    it "prevents a non-collaborator from creating character tags" do
      expect do
        post character_traits_path(character), params: { trait: { name: "Elf" } }
      end.not_to change(Trait, :count)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to include("owner or collaborator")
    end
  end

  describe "DELETE destroy" do
    it "prevents a non-collaborator from deleting character tags" do
      tag = create(:trait, character: character, name: "elf")

      expect do
        delete trait_path(tag)
      end.not_to change(Trait, :count)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to include("owner or collaborator")
    end
  end
end
