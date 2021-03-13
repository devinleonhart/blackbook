require "rails_helper"

RSpec.feature "Character#Show", :type => :feature do

  background {
    @user1 = FactoryBot.create(:user, {display_name: "User1", email: "user1@test.com", password: "abc123"})
    @user2 = FactoryBot.create(:user, {display_name: "User2", email: "user2@test.com", password: "abc123"})
    @universe1 = FactoryBot.create(:universe, {name: "Universe1", owner: @user1})
    @universe2 = FactoryBot.create(:universe, {name: "Universe2", owner: @user2})
    @character1 = FactoryBot.create(:character, {name: "Character1", universe: @universe1})
    @character2 = FactoryBot.create(:character, {name: "Character2", universe: @universe2})
    login_as(@user1)
  }

  scenario "should display the character's name." do
    visit character_url(@character1)

    expect(page).to have_text("Character1")
  end

  scenario "should not allow a user to view the show page of a character they do not own." do
    visit character_url(@character2)
    expect(page).to have_text("You are not an owner or collaborator of this universe.")
  end
end
