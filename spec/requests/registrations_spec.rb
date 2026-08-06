# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User registration", type: :request do
  it "permits display_name through the Devise parameter sanitizer on sign up" do
    expect do
      post user_registration_path, params: {
        user: {
          email: "newbie@example.com",
          password: "password123",
          password_confirmation: "password123",
          display_name: "Newbie"
        }
      }
    end.to change(User, :count).by(1)

    expect(User.find_by(email: "newbie@example.com")&.display_name).to eq("Newbie")
  end
end
