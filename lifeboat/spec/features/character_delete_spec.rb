# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Character#Delete", type: :feature do
  background do
    @user1 = FactoryBot.create(:user, { display_name: "User1", email: "user1@test.com", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user1 })
    @character1 = FactoryBot.create(:character, { name: "Character1", universe: @universe1 })
    login_as(@user1)
    visit edit_character_url(@character1)
  end

  scenario "should allow the delete of a character they own." do
    find_link("Delete").click
    expect(page).to have_text("Character deleted!")
    expect(page).not_to have_text("Character1")
    expect(Character.count).to eq(0)
  end
end
