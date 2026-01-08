# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin dashboard", type: :request do
  it "blocks non-admin users" do
    user = create(:user, admin: false)
    sign_in(user)

    get admin_root_path
    expect(response).to redirect_to(universes_url)
    expect(flash[:error]).to include("admin")
  end

  it "allows admins" do
    admin = create(:user, admin: true)
    sign_in(admin)

    get admin_root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Admin")
    expect(response.body).to include("User management")
    expect(response.body).to include("Dedupe")
  end
end
