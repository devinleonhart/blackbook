require "rails_helper"

RSpec.feature "Character#New", :type => :feature do

  background {
    @user1 = FactoryBot.create(:user, {display_name: "User1", email: "user1@test.com", password: "abc123"})
    @universe1 = FactoryBot.create(:universe, {name: "Universe1", owner: @user1})
    login_as(@user1)
    visit new_universe_character_url(@universe1)
  }

  scenario "should allow the creation of a new character with required fields." do
    fill_in "Name", with: "Max Lionheart"
    find_button("Save").click

    expect(page).to have_text("Character created!")
    expect(page).to have_text("Max Lionheart")
    expect(Character.count).to eq(1)
    expect(Character.all.first.name).to eq("Max Lionheart")
  end

  scenario "should not allow the creation of a character with a missing name." do
    fill_in "Name", with: ""
    find_button("Save").click

    expect(page).to have_text("Name can't be blank")
    expect(Character.count).to eq(0)
  end
end
