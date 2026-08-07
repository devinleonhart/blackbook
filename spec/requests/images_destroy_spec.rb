# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Images destroy", type: :request do
  include_context "with a signed-in owner"

  describe "DELETE destroy" do
    it "lets an owner delete their image" do
      image = create(:image, universe: universe)

      expect do
        delete universe_image_path(universe, image)
      end.to change(Image, :count).by(-1)

      expect(response).to redirect_to(universe_url(universe))
      expect(flash[:success]).to eq("Image deleted!")
    end

    it "redirects with a flash (not 500) when the image does not exist" do
      delete universe_image_path(universe, id: missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end
end
