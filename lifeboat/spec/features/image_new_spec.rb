# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Image#New", type: :feature do
  background do
    @user = FactoryBot.create(:user, { email: "user@test.com", password: "abc123" })
    @universe = FactoryBot.create(:universe, { name: "Universe1", owner: @user })
    login_as(@user)
  end

  scenario "should allow the upload of an image." do
    visit universe_url(@universe)

    within(".image-list") do
      expect(all(".img-thumbnail").count).to eq(0)
    end

    within(".image-list form") do
      attach_file("Image file", Rails.root.join("spec/fixtures/image.jpg"))
      find_button("Add").click
    end

    expect(page).to have_text("Image created!")
    expect(Image.count).to eq(1)

    visit universe_url(@universe)
    within(".image-list") do
      expect(all(".img-thumbnail").count).to eq(1)
    end
  end

  scenario "should not allow the upload of an image with no image given." do
    visit universe_url(@universe)
    within(".image-list form") do
      expect { find_button("Add").click }.to raise_error(/param is missing or the value is empty: image/)
    end
  end
end
