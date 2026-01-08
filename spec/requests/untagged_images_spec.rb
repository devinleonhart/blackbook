# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Untagged images filter", type: :request do
  it "shows only images with no characters tagged when filter=untagged" do
    user = create(:user)
    universe = create(:universe, owner: user)

    untagged_image = create(:image, universe: universe)
    tagged_image = create(:image, universe: universe)

    character = create(:character, universe: universe)
    create(:image_tag, image: tagged_image, character: character)

    sign_in(user)

    get universe_path(universe, filter: "untagged")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(edit_universe_image_path(universe, untagged_image))
    expect(response.body).not_to include(edit_universe_image_path(universe, tagged_image))
  end

  it "preserves filter=untagged in pagination links" do
    user = create(:user)
    universe = create(:universe, owner: user)

    # Force pagination (per_page is 20 on universes#show)
    create_list(:image, 25, universe: universe)

    sign_in(user)
    get universe_path(universe, filter: "untagged")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("filter=untagged")
    expect(response.body).to include("filter=untagged&amp;page=2")
  end
end
