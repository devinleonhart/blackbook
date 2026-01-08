# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users management", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "allows admins to delete a user" do
    admin = create(:user, admin: true)
    victim = create(:user)

    sign_in_as(admin)

    expect do
      delete user_path(victim)
    end.to change(User, :count).by(-1)

    expect(response).to redirect_to(users_url)
  end

  it "blocks non-admins from deleting users" do
    user = create(:user, admin: false)
    victim = create(:user)

    sign_in_as(user)
    delete user_path(victim)

    expect(response).to redirect_to(universes_url)
    expect(User.where(id: victim.id)).to exist
  end
end
