require "rails_helper"

RSpec.feature "Universe", :type => :feature do

  scenario "should allow the creation of a universe with correct fields." do
    login_as(FactoryBot.create(:user, {email: "test@test.com", password: "abc123"}))
    visit new_universe_url

    fill_in 'Name', with: "A Brand New Universe"
    find_button('Save').click

    expect(page).to have_text("Universe created!")
    expect(page).to have_text("A Brand New Universe")
  end

  scenario "should not allow the creation of a universe with a missing name." do
    login_as(FactoryBot.create(:user, {email: "test@test.com", password: "abc123"}))
    visit new_universe_url

    fill_in 'Name', with: ""
    find_button('Save').click

    expect(page).to have_text("Name can't be blank")
  end
end
