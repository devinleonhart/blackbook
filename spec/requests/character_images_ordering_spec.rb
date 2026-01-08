# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Character image ordering", type: :request do
  it "shows current_user favorited images first, without excluding images favorited by other users" do
    owner = create(:user)
    other_user = create(:user)

    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)

    image_a = create(:image, universe: universe)
    image_b = create(:image, universe: universe)
    create(:image_tag, image: image_a, character: character)
    create(:image_tag, image: image_b, character: character)

    # Other user's favorite should not affect the owner’s ordering or visibility
    create(:image_favorite, user: other_user, image: image_a)

    # Owner favorites image_b
    create(:image_favorite, user: owner, image: image_b)

    sign_in(owner)
    get character_path(character)

    expect(response).to have_http_status(:ok)

    url_a = edit_universe_image_path(universe, image_a)
    url_b = edit_universe_image_path(universe, image_b)

    idx_a = response.body.index(url_a)
    idx_b = response.body.index(url_b)

    expect(idx_a).not_to be_nil
    expect(idx_b).not_to be_nil
    expect(idx_b).to be < idx_a
  end
end
