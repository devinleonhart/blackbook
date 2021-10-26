# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Universe#Show", type: :feature do
  background do
    @user = FactoryBot.create(:user, { email: "user@test.com", display_name: "User", password: "abc123" })
    @other_user = FactoryBot.create(:user,
      { email: "other_user@test.com", display_name: "Other User", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user })
    @universe2 = FactoryBot.create(:universe, { name: "Universe2", owner: @other_user })
    @collaboration = FactoryBot.create(:collaboration, { universe: @universe1, user: @other_user })
    @character1 = FactoryBot.create(:character, { name: "Maximilian Lionheart", universe: @universe1 })
    @character2 = FactoryBot.create(:character, { name: "Lise Awen", universe: @universe1 })
    @character3 = FactoryBot.create(:character, { name: "Gina Sabatier", universe: @universe2 })
    @character4 = FactoryBot.create(:character, { name: "Simon Cooper", universe: @universe2 })
    @image1 = FactoryBot.create(:image, { universe: @universe1 })
    @image2 = FactoryBot.create(:image, { universe: @universe1 })
    login_as(@user)
  end

  scenario "should show a user his own universe." do
    visit universe_url(@universe1)
    expect(page).to have_text("Universe1")
  end

  scenario "should show the characters of that universe." do
    visit universe_url(@universe1)
    expect(find("#character-list")).to have_text("Maximilian Lionheart")
    expect(find("#character-list")).to have_text("Lise Awen")
    expect(find("#character-list")).not_to have_text("Gina Sabatier")
    expect(find("#character-list")).not_to have_text("Simon Cooper")
  end

  scenario "should navigate to the show page of the character when you click the characer card." do
    visit universe_url(@universe1)
    expect(find("#character-list").find(".card", match: :first)).to have_text("Lise Awen")
    find("#character-list").find(".card-link", match: :first).click
    expect(current_path).to eq(character_path(@character2))
  end

  scenario "should not show a user someone else's universe." do
    visit universe_url(@universe2)
    expect(page).not_to have_text("Universe2")
    expect(page).to have_text("You are not an owner or collaborator of this universe.")
  end

  scenario "should show the images of that universe." do
    visit universe_url(@universe1)
    expect(find("#image-list")).to have_selector(".image", count: 2)
  end

  scenario "should navigate to the edit page of an image when it is clicked." do
    visit universe_url(@universe1)
    find("#image-list").find(".image-link", match: :first).click
    expect(current_path).to eq(edit_universe_image_path(@universe1, @image2))
  end

  scenario "should list the owners and collaborators of the universe." do
    visit universe_url(@universe1)
    expect(page).to have_text("Owner: User")
    expect(page).to have_text("Collaborators: Other User")
  end
end
