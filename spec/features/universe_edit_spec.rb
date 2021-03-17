# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Universe#Edit", type: :feature do
  background do
    @user1 = FactoryBot.create(:user, { display_name: "User1", email: "user1@test.com", password: "abc123" })
    @user2 = FactoryBot.create(:user, { display_name: "User2", email: "user2@test.com", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user1 })
    login_as(@user1)
    visit edit_universe_url(@universe1)
  end

  scenario "should allow the edit of a universe with correct fields." do
    fill_in "Name", with: "A Brand New Universe"
    find_button("Save").click

    expect(page).to have_text("Universe updated!")
    expect(page).to have_text("A Brand New Universe")
    expect(Universe.count).to eq(1)
    expect(Universe.all.first.name).to eq("A Brand New Universe")
  end

  scenario "should not allow the edit of a universe with missing name." do
    fill_in "Name", with: ""
    find_button("Save").click

    expect(page).to have_text("Name can't be blank")
    expect(Universe.count).to eq(1)
    expect(Universe.all.first.name).to eq("Universe1")
  end
end
