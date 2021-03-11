require "rails_helper"

RSpec.feature "Universe", :type => :feature do


  scenario "User creates new universe" do
    login_as(FactoryBot.create(:user, {email: "test@test.com", password: "abc123"}))
    visit new_universe_url

    fill_in 'Name', with: "A Brand New Universe"
    find_button('Save').click

    expect(page).to have_text("Universe created!")
    expect(page).to have_text("A Brand New Universe")
  end
end
