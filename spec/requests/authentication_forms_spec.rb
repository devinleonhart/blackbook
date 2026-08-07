# frozen_string_literal: true

require "rails_helper"

# Guards the devise form_with conversions: the login form has no feature spec,
# so assert both that it renders the correct action/field names and that those
# params actually authenticate a user.
RSpec.describe "Authentication forms", type: :request do
  describe "sign in" do
    it "renders a form posting user credentials to the session path" do
      get new_user_session_path

      expect(response.body).to include('action="/users/sign_in"')
      expect(response.body).to include('name="user[email]"')
      expect(response.body).to include('name="user[password]"')
    end

    it "links to password recovery" do
      get new_user_session_path

      expect(response.body).to include(new_user_password_path)
      expect(response.body).to include("Forgot your password?")
    end

    it "signs the user in through those params" do
      user = create(:user, password: "password123", password_confirmation: "password123")

      post user_session_path, params: { user: { email: user.email, password: "password123" } }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end
  end

  describe "registration" do
    it "renders a form posting to the registration path with the expected fields" do
      get new_user_registration_path

      expect(response.body).to include('action="/users"')
      expect(response.body).to include('name="user[email]"')
      expect(response.body).to include('name="user[display_name]"')
    end
  end
end
