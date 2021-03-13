require "rails_helper"

RSpec.feature "Location#Delete", :type => :feature do

  background {
    @user1 = FactoryBot.create(:user, {display_name: "User1", email: "user1@test.com", password: "abc123"})
    @universe1 = FactoryBot.create(:universe, {name: "Universe1", owner: @user1})
    @location1 = FactoryBot.create(:location, {name: "Location1", universe: @universe1})
    login_as(@user1)
    visit edit_location_url(@location1)
  }

  scenario "should allow the delete of a location they own." do
    find_link("Delete").click
    expect(page).to have_text("Location deleted!")
    expect(page).not_to have_text("Location1")
    expect(Location.count).to eq(0)
  end
end
