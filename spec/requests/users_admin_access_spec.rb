# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User management access control", type: :request do
  describe "GET index" do
    context "when the user is not an admin" do
      it "redirects to universes with a flash" do
        sign_in(create(:user, admin: false))

        get users_path

        expect(response).to redirect_to(universes_url)
        expect(flash[:error]).to include("admin")
      end
    end

    context "when the user is an admin" do
      it "renders the user list" do
        sign_in(create(:user, admin: true))

        get users_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("User Management")
      end
    end
  end
end
