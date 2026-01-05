# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin dashboard", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "blocks non-admin users" do
    user = create(:user, password: "password123", admin: false)
    sign_in_as(user)

    get admin_root_path
    expect(response).to have_http_status(:found)
  end

  it "allows admins" do
    admin = create(:user, password: "password123", admin: true)
    sign_in_as(admin)

    get admin_root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Admin")
    expect(response.body).to include("User management")
    expect(response.body).to include("Dedupe")
  end
end
