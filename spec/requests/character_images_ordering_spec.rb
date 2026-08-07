# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Character image ordering", type: :request do
  include_context "with a signed-in owner"

  describe "GET show" do
    it "orders the current user's favorited images first, without hiding others' favorites" do
      character = create(:character, universe: universe)
      image_a = create(:image, universe: universe)
      image_b = create(:image, universe: universe)
      create(:appearance, image: image_a, character: character)
      create(:appearance, image: image_b, character: character)

      # Another user's favorite must not affect the owner's ordering or visibility.
      create(:image_favorite, user: create(:user), image: image_a)
      # The owner favorites image_b, so it should sort first.
      create(:image_favorite, user: owner, image: image_b)

      get character_path(character)

      expect(response).to have_http_status(:ok)
      idx_a = response.body.index(edit_universe_image_path(universe, image_a))
      idx_b = response.body.index(edit_universe_image_path(universe, image_b))

      expect(idx_a).not_to be_nil
      expect(idx_b).not_to be_nil
      expect(idx_b).to be < idx_a
    end
  end
end
