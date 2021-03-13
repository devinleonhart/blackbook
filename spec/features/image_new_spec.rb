require "rails_helper"

RSpec.feature "Universe#Show", :type => :feature do

  background {
    @user = FactoryBot.create(:user, {email: "user@test.com", password: "abc123"})
    @other_user = FactoryBot.create(:user, {email: "other_user@test.com", password: "abc123"})
    @universe1 = FactoryBot.create(:universe, {name: "Universe1", owner: @user})
    @universe2 = FactoryBot.create(:universe, {name: "Universe2", owner: @other_user})
    login_as(@user)
  }

  scenario "should allow the upload of an image." do
    visit universe_url(@universe1)

    within(".image-list") do
      expect(all('.img-thumbnail').count).to eq(0)
    end

    within(".image-list form") do
      attach_file("Image file", Rails.root + "spec/fixtures/image.jpg")
      find_button("Add").click
    end

    expect(page).to have_text("Image created!")
    expect(Image.count).to eq(1)
    within(".image-list") do
      expect(all('.img-thumbnail').count).to eq(1)
    end
  end

  scenario "should not allow the upload of an image with no image given." do
    visit universe_url(@universe1)
    within(".image-list form") do
      expect { find_button("Add").click }.to raise_error(/param is missing or the value is empty: image/)
    end
  end
end
