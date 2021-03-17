# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Collaboration#New", type: :feature do
  background do
    @user1 = FactoryBot.create(:user, { display_name: "User1", email: "user1@test.com", password: "abc123" })
    @user2 = FactoryBot.create(:user, { display_name: "User2", email: "user2@test.com", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user1 })
    login_as(@user1)
    visit edit_universe_url(@universe1)
  end

  scenario "should allow the adding of a collaborator with a provided display_name." do
    expect(page).to have_text("There are no collaborators in this universe.")

    select "User2", from: "collaboration_user_id"
    find_button("Add").click

    expect(find(".collaborators").find("li")).to have_text("User2")
    expect(find(".collaborators")).not_to have_text("There are no collaborators in this universe.")
    expect(Collaboration.count).to eq(1)
    expect(Collaboration.all.first.user.display_name).to eq("User2")
    expect(Collaboration.all.first.universe.name).to eq("Universe1")
  end

  scenario "should not allow the adding of a collaborator with a missing name." do
    select "", from: "collaboration_user_id"
    find_button("Add").click

    expect(page).to have_text("User must exist")
    expect(Collaboration.count).to eq(0)
  end

  scenario "should allow the removal of a collaborator." do
    select "User2", from: "collaboration_user_id"
    find_button("Add").click

    expect(find(".collaborators").find("li")).to have_text("User2")
    expect(find(".collaborators")).not_to have_text("There are no collaborators in this universe.")

    find(".collaborators").find("li").find("a").click

    expect(page).to have_text("There are no collaborators in this universe.")
    expect(find(".collaborators").find("li")).not_to have_text("User2")

    expect(Collaboration.count).to eq(0)
  end
end
