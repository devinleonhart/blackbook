# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Image#Edit", type: :feature do
  background do
    @user = FactoryBot.create(:user, { email: "user@test.com", password: "abc123" })
    @user2 = FactoryBot.create(:user, { email: "user2@test.com", password: "abc123" })
    @universe1 = FactoryBot.create(:universe, { name: "Universe1", owner: @user })
    @universe2 = FactoryBot.create(:universe, { name: "Universe2", owner: @user2 })
    @character1 = FactoryBot.create(:character, { name: "Max Lionheart", universe: @universe1 })
    @character2 = FactoryBot.create(:character, { name: "Lise Awen", universe: @universe1 })
    @image1 = FactoryBot.create(:image, { universe: @universe1 })
    @image2 = FactoryBot.create(:image, { universe: @universe2 })
    @image_tag = FactoryBot.create(:image_tag, { character: @character1, image: @image1 })
    login_as(@user)
    visit edit_universe_image_url(@universe1, @image1)
  end

  scenario "should not allow the edit of an image from another universe." do
    visit edit_universe_image_url(@universe2, @image2)
    expect(page).to have_text("You are not an owner or collaborator of this universe.")
  end

  scenario "should show the image is tagged by the character." do
    expect(find(".image-tags")).to have_text("Max Lionheart")
    within(".image-tags") do
      expect(all("li").count).to eq(1)
    end
  end

  scenario "should allow the creation of a new image tag." do
    select "Lise Awen", from: "image_tag[character_id]"
    find_button("Add").click
    expect(find(".image-tags")).to have_text("Lise Awen")
    within(".image-tags") do
      expect(all("li").count).to eq(2)
    end
  end

  scenario "should allow the deletion of an image tag." do
    find("a.delete-tag").click
    expect(find(".image-tags")).not_to have_text("Maximilian Lionheart")
    expect(find(".image-tags")).to have_text("There are no characters in this image.")
    within(".image-tags") do
      expect(all("li").count).to eq(1)
    end
  end

  scenario "should allow an image to be set as an avatar." do
    check("avatarCheckbox")
    find_button("Update").click
    expect(Image.all.first.avatar).to eq(true)
  end

  scenario "should allow an image to be set as a universe avatar." do
    check("universeAvatarCheckbox")
    find_button("Update").click
    expect(Image.all.first.universe_avatar).to eq(true)
  end

  scenario "should allow an image to be deleted." do
    find_link("Delete").click
    expect(Image.count).to eq(1)
  end
end
