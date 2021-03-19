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

  scenario "should allow adding a trait." do
    visit edit_character_url(@character1)
    fill_in "character_trait[trait_name]", with: "Strong"
    within(".character-trait-list") do
      find_button("Add").click
    end
    expect(CharacterTrait.count).to eq(1)
    expect(page).to have_text("Strong")
  end

  scenario "should not allow adding a trait without a name." do
    visit edit_character_url(@character1)
    fill_in "character_trait[trait_name]", with: ""
    within(".character-trait-list") do
      find_button("Add").click
    end
    expect(CharacterTrait.count).to eq(0)
    expect(page).not_to have_text("Strong")
    expect(page).to have_text("You must provide a name.")
  end

  scenario "should allow deleting a trait." do
    trait = FactoryBot.create(:trait, name: "Strong")
    FactoryBot.create(:character_trait, trait: trait, character: @character1)
    visit edit_character_url(@character1)
    within(".character-trait-list") do
      find(".trait", match: :first).find("a").click
    end
    expect(CharacterTrait.count).to eq(0)
  end

  scenario "should allow adding an item." do
    visit edit_character_url(@character1)
    fill_in "character_item[item_name]", with: "Sword"
    within(".character-item-list") do
      find_button("Add").click
    end
    expect(CharacterItem.count).to eq(1)
    expect(page).to have_text("Sword")
  end

  scenario "should not allow adding an item without a name." do
    visit edit_character_url(@character1)
    fill_in "character_item[item_name]", with: ""
    within(".character-item-list") do
      find_button("Add").click
    end
    expect(CharacterItem.count).to eq(0)
    expect(page).to have_text("You must provide a name.")
  end

  scenario "should allow deleting an item." do
    item = FactoryBot.create(:item, name: "Sword")
    FactoryBot.create(:character_item, item: item, character: @character1)
    visit edit_character_url(@character1)
    within(".character-item-list") do
      find(".item", match: :first).find("a").click
    end
    expect(CharacterItem.count).to eq(0)
    expect(page).not_to have_text("Sword")
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
