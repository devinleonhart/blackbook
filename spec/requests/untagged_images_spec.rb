# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Untagged images filter", type: :request do
  include_context "with a signed-in owner"

  describe "GET show with filter=untagged" do
    it "shows only images that have no characters tagged" do
      untagged_image = create(:image, universe: universe)
      tagged_image = create(:image, universe: universe)
      character = create(:character, universe: universe)
      create(:appearance, image: tagged_image, character: character)

      get universe_path(universe, filter: "untagged")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(edit_universe_image_path(universe, untagged_image))
      expect(response.body).not_to include(edit_universe_image_path(universe, tagged_image))
    end

    it "preserves the filter in pagination links" do
      create_list(:image, 25, universe: universe) # per_page is 20 on universes#show

      get universe_path(universe, filter: "untagged")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("filter=untagged")
      expect(response.body).to include("filter=untagged&amp;page=2")
    end
  end
end
