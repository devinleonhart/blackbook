# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Location#New", type: :feature do
  background do
    @user1 = FactoryBot.create(:user, { display_name: "User1", email: "user1@test.com", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user1 })
    login_as(@user1)
    visit new_universe_location_url(@universe1)
  end

  scenario "should allow the creation of a new location with required fields." do
    fill_in "Name", with: "Seraph"
    find_button("Save").click

    expect(page).to have_text("Location created!")
    expect(page).to have_text("Seraph")
    expect(Location.count).to eq(1)
    expect(Location.all.first.name).to eq("Seraph")
  end

  scenario "should not allow the creation of a location with a missing name." do
    fill_in "Name", with: ""
    find_button("Save").click

    expect(page).to have_text("Name can't be blank")
    expect(Location.count).to eq(0)
  end
end
