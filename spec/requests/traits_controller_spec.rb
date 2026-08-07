# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Traits", type: :request do
  include_context "with a signed-in owner"

  let(:character) { create(:character, universe: universe) }

  describe "GET index" do
    it "lists the character's tags" do
      create(:trait, character: character, name: "elf")

      get character_traits_path(character)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("elf")
    end
  end

  describe "GET show" do
    it "shows a tag and its related characters" do
      tag = create(:trait, character: character, name: "mage")
      image = create(:image, universe: universe)
      create(:appearance, image: image, character: character)

      get trait_path(tag)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("mage")
    end
  end

  describe "GET edit" do
    it "renders the edit form" do
      tag = create(:trait, character: character, name: "human")

      get edit_trait_path(tag)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST create" do
    context "with a valid name" do
      it "creates the tag (normalized to lowercase) and redirects to the character" do
        expect do
          post character_traits_path(character), params: { trait: { name: "Elf" } }
        end.to change(character.traits, :count).by(1)

        expect(response).to redirect_to(character_path(character))
        expect(character.traits.reload.map(&:name)).to include("elf")
        expect(flash[:success]).to be_present
      end
    end

    context "with an invalid name" do
      it "does not create the tag and redirects back to the tag list with a flash" do
        expect do
          post character_traits_path(character), params: { trait: { name: "" } }
        end.not_to change(Trait, :count)

        expect(response).to redirect_to(character_traits_path(character))
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "PATCH update" do
    context "with a valid name" do
      it "updates the tag and redirects to the tag list" do
        tag = create(:trait, character: character, name: "human")

        patch trait_path(tag), params: { trait: { name: "noble" } }

        expect(response).to redirect_to(character_traits_path(character))
        expect(tag.reload.name).to eq("noble")
      end
    end

    context "with an invalid name" do
      it "re-renders edit with an unprocessable status" do
        tag = create(:trait, character: character, name: "human")

        patch trait_path(tag), params: { trait: { name: "" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(tag.reload.name).to eq("human")
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the tag and redirects to the tag list" do
      tag = create(:trait, character: character, name: "warrior")

      expect do
        delete trait_path(tag)
      end.to change(Trait, :count).by(-1)

      expect(response).to redirect_to(character_traits_path(character))
    end
  end

  describe "authentication" do
    before { sign_out(owner) }

    it "redirects unauthenticated users to sign in" do
      get character_traits_path(character)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
