# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Universe#New", type: :feature do
  background do
    login_as(FactoryBot.create(:user, { email: "user@test.com", password: "abc123" }))
    visit new_universe_url
  end

  scenario "should allow the creation of a universe with correct fields." do
    fill_in "Name", with: "A Brand New Universe"
    find_button("Save").click

    expect(page).to have_text("Universe created!")
    expect(page).to have_text("A Brand New Universe")
    expect(Universe.count).to eq(1)
    expect(Universe.all.first.name).to eq("A Brand New Universe")
  end

  scenario "should allow the creation of a universe with correct fields." do
    fill_in "Name", with: "A Brand New Universe"
    find_button("Save").click

    expect(page).to have_text("Universe created!")
    expect(page).to have_text("A Brand New Universe")
  end

  scenario "should not allow the creation of a universe with a missing name." do
    fill_in "Name", with: ""
    find_button("Save").click

    expect(page).to have_text("Name can't be blank")
    expect(Universe.count).to eq(0)
  end
end
