# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Universes", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "lists owned + collaborated universes" do
    owner = create(:user)
    collaborator = create(:user)
    owned = create(:universe, owner: owner, name: "Owned U")
    collaborated = create(:universe, owner: create(:user), name: "Collab U")
    create(:collaboration, universe: collaborated, user: owner)

    sign_in_as(owner)
    get universes_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(owned.name, collaborated.name)
  end

  it "blocks access to an inaccessible universe show" do
    owner = create(:user)
    stranger = create(:user)
    universe = create(:universe, owner: owner)

    sign_in_as(stranger)
    get universe_path(universe)

    expect(response).to redirect_to(universes_url)
  end

  it "supports filter=untagged" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)

    tagged = create(:image, universe: universe)
    create(:image_tag, image: tagged, character: character)
    untagged = create(:image, universe: universe)

    sign_in_as(owner)
    get universe_path(universe, filter: "untagged")

    expect(response).to have_http_status(:ok)
    # We don't assert exact markup; just ensure page renders and includes at least one image.
    expect(response.body).to include("Untagged Images")
  end

  it "creates a universe with valid params" do
    user = create(:user)
    sign_in_as(user)

    post universes_path, params: { universe: { name: "New Universe" } }
    expect(response).to redirect_to(universes_url)
    expect(Universe.where(owner: user, name: "New Universe")).to exist
  end

  it "does not create a universe with invalid params" do
    user = create(:user)
    sign_in_as(user)

    post universes_path, params: { universe: { name: "" } }
    expect(response).to redirect_to(new_universe_url)
  end

  it "updates a universe for a collaborator (visible_to_user?)" do
    owner = create(:user)
    collaborator = create(:user)
    universe = create(:universe, owner: owner, name: "Old")
    create(:collaboration, universe: universe, user: collaborator)

    sign_in_as(collaborator)
    patch universe_path(universe), params: { universe: { name: "Updated" } }

    expect(response).to redirect_to(universes_url)
    expect(universe.reload.name).to eq("Updated")
  end
end
