require "rails_helper"

RSpec.feature "Location#Edit", :type => :feature do

  background {
    @user1 = FactoryBot.create(:user, {display_name: "User1", email: "user1@test.com", password: "abc123"})
    @universe1 = FactoryBot.create(:universe, {name: "Universe1", owner: @user1})
    @location1 = FactoryBot.create(:location, {name: "Location1", universe: @universe1})
    login_as(@user1)
    visit edit_location_url(@location1)
  }

  scenario "should allow the edit of a location with required fields." do
    fill_in "Name", with: "Seraph"
    find_button("Save").click

    expect(page).to have_text("Location updated!")
    expect(page).to have_text("Seraph")
    expect(Location.count).to eq(1)
    expect(Location.all.first.name).to eq("Seraph")
  end

  scenario "should not allow the edit of a location with a missing name." do
    fill_in "Name", with: ""
    find_button("Save").click

    expect(page).to have_text("Name can't be blank")
    expect(Location.count).to eq(1)
    expect(Location.all.first.name).to eq("Location1")
  end
end
