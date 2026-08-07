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

      it "shows each user's owned universes and images" do
        admin = create(:user, admin: true)
        universe = create(:universe, owner: admin)
        create(:image, universe: universe)

        sign_in(admin)
        get users_path

        expect(response.body).to include("1 universe", "1 image")
      end
    end
  end

  describe "PATCH toggle_admin" do
    it "promotes a non-admin" do
      sign_in(create(:user, admin: true))
      target = create(:user, admin: false)

      patch toggle_admin_user_path(target)

      expect(target.reload.admin).to be(true)
      expect(response).to redirect_to(users_url)
    end

    it "demotes an admin" do
      sign_in(create(:user, admin: true))
      target = create(:user, admin: true)

      patch toggle_admin_user_path(target)

      expect(target.reload.admin).to be(false)
    end

    it "does not let an admin change their own status" do
      admin = create(:user, admin: true)
      sign_in(admin)

      patch toggle_admin_user_path(admin)

      expect(admin.reload.admin).to be(true)
      expect(flash[:error]).to be_present
    end

    it "redirects a non-admin with a flash" do
      sign_in(create(:user, admin: false))
      target = create(:user)

      patch toggle_admin_user_path(target)

      expect(target.reload.admin).to be(false)
      expect(response).to redirect_to(universes_url)
    end

    it "redirects with a flash when the user does not exist" do
      sign_in(create(:user, admin: true))

      patch toggle_admin_user_path(missing_id)

      expect(response).to redirect_to(users_url)
      expect(flash[:error]).to be_present
    end
  end
end
