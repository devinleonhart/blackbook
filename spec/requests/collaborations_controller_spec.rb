# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collaborations", type: :request do
  it "redirects unauthenticated users from creating a collaboration" do
    universe = create(:universe)
    post universe_collaborations_path(universe), params: { collaboration: { user_id: 123 } }
    expect(response).to have_http_status(:found)
  end

  it "creates a collaboration and redirects to universe edit" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    collaborator = create(:user)

    sign_in(owner)
    post universe_collaborations_path(universe), params: { collaboration: { user_id: collaborator.id } }

    expect(response).to redirect_to(edit_universe_url(universe))
    expect(Collaboration.where(universe: universe, user: collaborator)).to exist
  end

  it "does not create invalid collaboration (duplicate) but still redirects to universe edit" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    collaborator = create(:user)
    create(:collaboration, universe: universe, user: collaborator)

    sign_in(owner)
    expect do
      post universe_collaborations_path(universe), params: { collaboration: { user_id: collaborator.id } }
    end.not_to change(Collaboration, :count)

    expect(response).to redirect_to(edit_universe_url(universe))
  end

  it "shows a collaboration" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    collaborator = create(:user)
    collab = create(:collaboration, universe: universe, user: collaborator)

    sign_in(owner)
    get collaboration_path(collab)
    # There is no HTML template for this action today, so Rails returns 406.
    # (This still exercises the controller lookup paths.)
    expect(response).to have_http_status(:not_acceptable)
  end

  it "destroys a collaboration and redirects to universe edit" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    collaborator = create(:user)
    collab = create(:collaboration, universe: universe, user: collaborator)

    sign_in(owner)
    expect do
      delete collaboration_path(collab)
    end.to change(Collaboration, :count).by(-1)

    expect(response).to redirect_to(edit_universe_url(universe.id))
  end
end
