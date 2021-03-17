# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Character#Edit", type: :feature do
  background do
    @user1 = FactoryBot.create(:user, { display_name: "User1", email: "user1@test.com", password: "abc123" })
    @user2 = FactoryBot.create(:user, { display_name: "User2", email: "user2@test.com", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user1 })
    @universe2 = FactoryBot.create(:universe, { name: "Universe2", owner: @user2 })
    @character1 = FactoryBot.create(:character, { name: "Character1", universe: @universe1 })
    @character2 = FactoryBot.create(:character, { name: "Character2", universe: @universe2 })
    login_as(@user1)
  end

  scenario "should allow the edit of a character with required fields." do
    visit edit_character_url(@character1)
    fill_in "Name", with: "Max Lionheart"
    find_button("Save").click

    expect(page).to have_text("Character updated!")
    expect(page).to have_text("Max Lionheart")
    expect(Character.count).to eq(2)
    expect(Character.all.first.name).to eq("Max Lionheart")
  end

  scenario "should not allow the edit of a character with a missing name." do
    visit edit_character_url(@character1)
    fill_in "Name", with: ""
    find_button("Save").click

    expect(page).to have_text("Name can't be blank")
    expect(Character.count).to eq(2)
    expect(Character.all.first.name).to eq("Character1")
  end

  scenario "should not allow a user to view the edit page of a character they do not own." do
    visit edit_character_url(@character2)
    expect(page).to have_text("You are not an owner or collaborator of this universe.")
  end
end
