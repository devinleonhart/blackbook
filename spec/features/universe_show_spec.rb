# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Universe#Show", type: :feature do
  background do
    @user = FactoryBot.create(:user, { email: "user@test.com", password: "abc123" })
    @other_user = FactoryBot.create(:user, { email: "other_user@test.com", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user })
    @universe2 = FactoryBot.create(:universe, { name: "Universe2", owner: @other_user })
    login_as(@user)
  end

  scenario "should show a user his own universe." do
    visit universe_url(@universe1)
    expect(page).to have_text("Universe1")
  end

  scenario "should not show a user someone else's universe." do
    visit universe_url(@universe2)
    expect(page).not_to have_text("Universe2")
    expect(page).to have_text("You are not an owner or collaborator of this universe.")
  end
end
