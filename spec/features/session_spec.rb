# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Session", type: :feature do
  before do
    FactoryBot.create(:user, { email: "user@test.com", password: "abc123" })
    visit new_user_session_url
  end

  scenario "should allow the user to log in with correct credentials." do
    fill_in("Email", with: "user@test.com")
    fill_in("Password", with: "abc123")
    find_button("Sign In").click

    expect(page).to have_text("Signed in successfully.")
  end

  scenario "should not allow a user to log in with an email that doesn't exist." do
    fill_in("Email", with: "wrong email")
    fill_in("Password", with: "abc123")
    find_button("Sign In").click

    expect(page).to have_text("Invalid Email or password.")
  end

  scenario "should not allow a user to log in with an incorrect password." do
    fill_in("Email", with: "user@test.com")
    fill_in("Password", with: "wrong password")
    find_button("Sign In").click

    expect(page).to have_text("Invalid Email or password.")
  end
end
