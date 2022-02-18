# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Character#Edit", type: :feature do
  background do
    @user1 = FactoryBot.create(:user, { display_name: "User1", email: "user1@test.com", password: "abc123" })
    @user2 = FactoryBot.create(:user, { display_name: "User2", email: "user2@test.com", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user1 })
    @universe2 = FactoryBot.create(:universe, { name: "Universe2", owner: @user2 })
    @character1 = FactoryBot.create(:character, { name: "Maximilian Lionheart", universe: @universe1 })
    @character2 = FactoryBot.create(:character, { name: "Lise Awen", universe: @universe1 })
    @character3 = FactoryBot.create(:character, { name: "Gina Sabatier", universe: @universe2 })
    login_as(@user1)
  end

  scenario "should allow the edit of a character with required fields." do
    visit edit_character_url(@character1)
    fill_in "Name", with: "Max Lionheart"
    find_button("Save").click

    expect(page).to have_text("Character updated!")
    expect(page).to have_text("Max Lionheart")
    expect(Character.count).to eq(3)
    expect(Character.all.first.name).to eq("Max Lionheart")
  end

  scenario "should not allow the edit of a character with a missing name." do
    visit edit_character_url(@character1)
    fill_in "Name", with: ""
    find_button("Save").click

    expect(page).to have_text("Name can't be blank")
    expect(Character.count).to eq(3)
    expect(Character.all.first.name).to eq("Maximilian Lionheart")
  end

  scenario "should not allow a user to view the edit page of a character they do not own." do
    visit edit_character_url(@character3)
    expect(page).to have_text("You are not an owner or collaborator of this universe.")
  end

  scenario "should allow a valid relationship." do
    visit edit_character_url(@character1)
    within(".new-relationship-form") do
      select("Lise Awen", from: "mutual_relationship[target_character_id]")
      fill_in("mutual_relationship[forward_name]", with: "Boyfriend")
      fill_in("mutual_relationship[reverse_name]", with: "Girlfriend")
      find_button("Add").click
    end
    expect(find(".relationship-table")).to have_text("Lise Awen")
    expect(find(".relationship-table")).to have_text("Boyfriend")

    visit edit_character_url(@character2)
    expect(find(".relationship-table")).to have_text("Maximilian Lionheart")
    expect(find(".relationship-table")).to have_text("Girlfriend")
  end

  scenario "should allow relationship to be deleted." do
    FactoryBot.create(:mutual_relationship,
      character_universe: @universe1,
      character1: @character1,
      character2: @character2,
      forward_name: "Boyfriend",
      reverse_name: "Girlfriend")
    visit edit_character_url(@character1)

    expect(find(".relationship-table")).to have_text("Maximilian Lionheart")
    expect(find(".relationship-table")).to have_text("Boyfriend")

    find(".relationship-table").find(".btn-close", match: :first).click

    expect(find(".relationship-table")).not_to have_text("Maximilian Lionheart")
    expect(find(".relationship-table")).not_to have_text("Boyfriend")
    expect(page).to have_text("This character has no relationships.")
  end

  scenario "should not allow a relationship without a target character." do
    visit edit_character_url(@character1)
    within(".new-relationship-form") do
      fill_in("mutual_relationship[forward_name]", with: "Boyfriend")
      fill_in("mutual_relationship[reverse_name]", with: "Girlfriend")
      find_button("Add").click
    end
    expect(page).to have_text("One of the two characters you are trying to relate does not exist.")
  end

  scenario "should not allow a relationship without a forward name." do
    visit edit_character_url(@character1)
    within(".new-relationship-form") do
      select("Lise Awen", from: "mutual_relationship[target_character_id]")
      fill_in("mutual_relationship[forward_name]", with: "")
      fill_in("mutual_relationship[reverse_name]", with: "Girlfriend")
      find_button("Add").click
    end
    expect(page).to have_text("Both directions of the relationship must be specified.")
  end

  scenario "should not allow a relationship without a reverse name." do
    visit edit_character_url(@character1)
    within(".new-relationship-form") do
      select("Lise Awen", from: "mutual_relationship[target_character_id]")
      fill_in("mutual_relationship[forward_name]", with: "Boyfriend")
      fill_in("mutual_relationship[reverse_name]", with: "")
      find_button("Add").click
    end
    expect(page).to have_text("Both directions of the relationship must be specified.")
  end
end
