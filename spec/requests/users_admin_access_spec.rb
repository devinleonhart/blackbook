# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User management access control", type: :request do
  it "blocks non-admin users from /users" do
    user = create(:user, admin: false)
    sign_in(user)

    get users_path
    expect(response).to have_http_status(:found)
  end

  it "allows admins to view /users" do
    admin = create(:user, admin: true)
    sign_in(admin)

    get users_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("User Management")
  end
end
