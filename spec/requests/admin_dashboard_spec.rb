# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin dashboard", type: :request do
  describe "GET admin root" do
    context "when the user is not an admin" do
      it "redirects to universes with a flash" do
        sign_in(create(:user, admin: false))

        get admin_root_path

        expect(response).to redirect_to(universes_url)
        expect(flash[:error]).to include("admin")
      end
    end

    context "when the user is an admin" do
      it "renders the dashboard" do
        sign_in(create(:user, admin: true))

        get admin_root_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Admin", "User management", "Dedupe")
      end
    end
  end
end
