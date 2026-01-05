# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User management access control", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "blocks non-admin users from /users" do
    user = create(:user, password: "password123", admin: false)
    sign_in_as(user)

    get users_path
    expect(response).to have_http_status(:found)
  end

  it "allows admins to view /users" do
    admin = create(:user, password: "password123", admin: true)
    sign_in_as(admin)

    get users_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("User Management")
  end
end
