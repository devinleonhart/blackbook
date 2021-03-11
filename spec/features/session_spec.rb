require "rails_helper"

RSpec.feature "Session", :type => :feature do

  scenario "should allow the user to log in with correct credentials." do
    FactoryBot.create(:user, {email: "test@test.com", password: "abc123"})
    visit new_user_session_url
    fill_in('Email', with: "test@test.com")
    fill_in('Password', with: "abc123")
    find_button('Sign In').click

    expect(page).to have_text("Signed in successfully.")
  end

  scenario "should not allow a user to log in with an email that doesn't exist." do
    FactoryBot.create(:user, {email: "test@test.com", password: "abc123"})
    visit new_user_session_url
    fill_in('Email', with: "wrong email")
    fill_in('Password', with: "abc123")
    find_button('Sign In').click

    expect(page).to have_text("Invalid Email or password.")
  end

  scenario "should not allow a user to log in with an incorrect password." do
    FactoryBot.create(:user, {email: "test@test.com", password: "abc123"})
    visit new_user_session_url
    fill_in('Email', with: "test@test.com")
    fill_in('Password', with: "wrong password")
    find_button('Sign In').click

    expect(page).to have_text("Invalid Email or password.")
  end
end
