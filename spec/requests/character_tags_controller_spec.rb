# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CharacterTags", type: :request do
  include_context "with a signed-in owner"

  let(:character) { create(:character, universe: universe) }

  describe "GET index" do
    it "lists the character's tags" do
      create(:character_tag, character: character, name: "elf")

      get character_character_tags_path(character)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("elf")
    end
  end

  describe "GET show" do
    it "shows a tag and its related characters" do
      tag = create(:character_tag, character: character, name: "mage")
      image = create(:image, universe: universe)
      create(:image_tag, image: image, character: character)

      get character_tag_path(tag)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("mage")
    end
  end

  describe "GET edit" do
    it "renders the edit form" do
      tag = create(:character_tag, character: character, name: "human")

      get edit_character_tag_path(tag)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST create" do
    context "with a valid name" do
      it "creates the tag (normalized to lowercase) and redirects to the character" do
        expect do
          post character_character_tags_path(character), params: { character_tag: { name: "Elf" } }
        end.to change(character.character_tags, :count).by(1)

        expect(response).to redirect_to(character_path(character))
        expect(character.character_tags.reload.map(&:name)).to include("elf")
        expect(flash[:success]).to be_present
      end
    end

    context "with an invalid name" do
      it "does not create the tag and redirects back to the tag list with a flash" do
        expect do
          post character_character_tags_path(character), params: { character_tag: { name: "" } }
        end.not_to change(CharacterTag, :count)

        expect(response).to redirect_to(character_character_tags_path(character))
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "PATCH update" do
    context "with a valid name" do
      it "updates the tag and redirects to the tag list" do
        tag = create(:character_tag, character: character, name: "human")

        patch character_tag_path(tag), params: { character_tag: { name: "noble" } }

        expect(response).to redirect_to(character_character_tags_path(character))
        expect(tag.reload.name).to eq("noble")
      end
    end

    context "with an invalid name" do
      it "re-renders edit with an unprocessable status" do
        tag = create(:character_tag, character: character, name: "human")

        patch character_tag_path(tag), params: { character_tag: { name: "" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(tag.reload.name).to eq("human")
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the tag and redirects to the tag list" do
      tag = create(:character_tag, character: character, name: "warrior")

      expect do
        delete character_tag_path(tag)
      end.to change(CharacterTag, :count).by(-1)

      expect(response).to redirect_to(character_character_tags_path(character))
    end
  end

  describe "authentication" do
    before { sign_out(owner) }

    it "redirects unauthenticated users to sign in" do
      get character_character_tags_path(character)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
