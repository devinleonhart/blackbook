require "rails_helper"

RSpec.feature "Universe#Index", :type => :feature do

  background {
    @user = FactoryBot.create(:user, {email: "user@test.com", password: "abc123"})
    @other_user = FactoryBot.create(:user, {email: "other_user@test.com", password: "abc123"})
    login_as(@user)
    @universe1 = FactoryBot.create(:universe, {name: "Universe1", owner: @user})
    @universe2 = FactoryBot.create(:universe, {name: "Universe2", owner: @user})
    @universe3 = FactoryBot.create(:universe, {name: "Universe3", owner: @user})
    @universe4 = FactoryBot.create(:universe, {name: "Universe4", owner: @other_user})
    visit universes_url
  }

  scenario "should only show a user his own universes." do
    expect(page).to have_text("Universe1")
    expect(page).to have_text("Universe2")
    expect(page).to have_text("Universe3")
    expect(page).not_to have_text("Universe4")
    expect(Universe.count).to eq(4)
  end

  scenario "should reflect when a universe is deleted." do
    Universe.find_by({name: "Universe1"}).delete
    visit current_path
    expect(page).not_to have_text("Universe1")
    expect(page).to have_text("Universe2")
    expect(page).to have_text("Universe3")
    expect(page).not_to have_text("Universe4")
    expect(Universe.count).to eq(3)
  end

  scenario "should see his own universes and universes he is collaborating on." do
    FactoryBot.create(:collaboration, {universe: @universe4, user: @user})
    visit current_path
    expect(page).to have_text("Universe1")
    expect(page).to have_text("Universe2")
    expect(page).to have_text("Universe3")
    expect(page).to have_text("Universe4")
    expect(Universe.count).to eq(4)
  end
end
