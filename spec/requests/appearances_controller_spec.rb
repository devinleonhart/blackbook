# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Appearances", type: :request do
  include_context "with a signed-in owner"

  let(:character) { create(:character, universe: universe) }
  let(:image) { create(:image, universe: universe) }

  describe "POST create" do
    it "creates an image tag and redirects to the image edit page" do
      expect do
        post universe_image_appearances_path(universe, image), params: { appearance: { character_id: character.id } }
      end.to change(Appearance, :count).by(1)

      expect(response).to redirect_to(edit_universe_image_url(universe, image))
    end

    context "when unauthenticated" do
      before { sign_out(owner) }

      it "redirects to sign in without creating a tag" do
        expect do
          post universe_image_appearances_path(universe, image), params: { appearance: { character_id: character.id } }
        end.not_to change(Appearance, :count)

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user cannot access the universe" do
      before { sign_in(create(:user)) }

      it "does not create the tag and redirects (authorizes before persisting)" do
        expect do
          post universe_image_appearances_path(universe, image), params: { appearance: { character_id: character.id } }
        end.not_to change(Appearance, :count)

        expect(response).to redirect_to(universes_url)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the image tag and redirects to the image edit page" do
      appearance = create(:appearance, image: image, character: character)

      expect do
        delete appearance_path(appearance)
      end.to change(Appearance, :count).by(-1)

      expect(response).to redirect_to(edit_universe_image_url(universe, image))
    end

    it "redirects with a flash when the image tag does not exist" do
      delete appearance_path(missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end
end
