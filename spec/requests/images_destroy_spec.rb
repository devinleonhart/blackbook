# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images destroy", type: :request do
  describe "DELETE destroy" do
    it "lets an owner delete their image" do
      user = create(:user)
      universe = create(:universe, owner: user)
      image = create(:image, universe: universe)

      sign_in(user)
      expect do
        delete universe_image_path(universe, image)
      end.to change(Image, :count).by(-1)

      expect(response).to redirect_to(universe_url(universe))
      expect(flash[:success]).to eq("Image deleted!")
    end

    it "redirects with a flash (not 500) when the image does not exist" do
      user = create(:user)
      universe = create(:universe, owner: user)

      sign_in(user)
      delete universe_image_path(universe, id: 999_999)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end
end
