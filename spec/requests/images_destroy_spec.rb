# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images destroy", type: :request do
  include_context "with a signed-in owner"

  describe "DELETE destroy" do
    it "lets an owner delete their image" do
      image = create(:image, universe: universe)

      expect do
        delete universe_image_path(universe, image)
      end.to change(Image, :count).by(-1)

      expect(response).to redirect_to(universe_url(universe))
      expect(flash[:success]).to eq("Image deleted!")
    end

    it "redirects to the originating character when a character_id is given" do
      character = create(:character, universe: universe)
      image = create(:image, universe: universe)
      create(:appearance, character: character, image: image)

      delete universe_image_path(universe, image), params: { character_id: character.id }

      expect(response).to redirect_to(character_url(character))
      expect(flash[:success]).to eq("Image deleted!")
    end

    it "still redirects to the character even when it has no images left" do
      character = create(:character, universe: universe)
      image = create(:image, universe: universe)
      create(:appearance, character: character, image: image)

      delete universe_image_path(universe, image), params: { character_id: character.id }

      expect(character.reload.appearances).to be_empty
      expect(response).to redirect_to(character_url(character))
    end

    it "falls back to the universe when the character_id belongs to another universe" do
      other_character = create(:character)
      image = create(:image, universe: universe)

      delete universe_image_path(universe, image), params: { character_id: other_character.id }

      expect(response).to redirect_to(universe_url(universe))
    end

    it "redirects with a flash (not 500) when the image does not exist" do
      delete universe_image_path(universe, id: missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end
end
