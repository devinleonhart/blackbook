require "rails_helper"

RSpec.feature "Location#Show", :type => :feature do

  background {
    @user1 = FactoryBot.create(:user, {display_name: "User1", email: "user1@test.com", password: "abc123"})
    @user2 = FactoryBot.create(:user, {display_name: "User2", email: "user2@test.com", password: "abc123"})
    @universe1 = FactoryBot.create(:universe, {name: "Universe1", owner: @user1})
    @universe2 = FactoryBot.create(:universe, {name: "Universe2", owner: @user2})
    @location1 = FactoryBot.create(:location, {name: "Location1", universe: @universe1})
    @location2 = FactoryBot.create(:location, {name: "Location2", universe: @universe2})
    login_as(@user1)
  }

  scenario "should display the locations's name." do
    visit location_url(@location1)

    expect(page).to have_text("Location1")
  end

  scenario "should not allow a user to view the show page of a location they do not own." do
    visit location_url(@location2)
    expect(page).to have_text("You are not an owner or collaborator of this universe.")
  end
end
