# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images edit", type: :request do
  include_context "with a signed-in owner"

  let(:image) { create(:image, universe: universe) }

  it "renders the edit page for an accessible image" do
    get edit_universe_image_path(universe, image)

    expect(response).to have_http_status(:ok)
  end

  it "redirects with a flash when the image does not exist" do
    get edit_universe_image_path(universe, id: missing_id)

    expect(response).to redirect_to(universes_url)
    expect(flash[:error]).to be_present
  end

  it "redirects a stranger who cannot access the image's universe" do
    stranger = create(:user)
    sign_in(stranger)

    get edit_universe_image_path(universe, image)

    expect(response).to redirect_to(universes_url)
    expect(flash[:error]).to be_present
  end
end
