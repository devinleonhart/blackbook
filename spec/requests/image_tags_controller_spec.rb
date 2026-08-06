# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ImageTags", type: :request do
  include_context "with a signed-in owner"

  let(:character) { create(:character, universe: universe) }
  let(:image) { create(:image, universe: universe) }

  describe "POST create" do
    it "creates an image tag and redirects to the image edit page" do
      expect do
        post universe_image_image_tags_path(universe, image), params: { image_tag: { character_id: character.id } }
      end.to change(ImageTag, :count).by(1)

      expect(response).to redirect_to(edit_universe_image_url(universe, image))
    end

    context "when unauthenticated" do
      before { sign_out(owner) }

      it "redirects to sign in without creating a tag" do
        expect do
          post universe_image_image_tags_path(universe, image), params: { image_tag: { character_id: character.id } }
        end.not_to change(ImageTag, :count)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the image tag and redirects to the image edit page" do
      image_tag = create(:image_tag, image: image, character: character)

      expect do
        delete image_tag_path(image_tag)
      end.to change(ImageTag, :count).by(-1)

      expect(response).to redirect_to(edit_universe_image_url(universe, image))
    end

    it "redirects with a flash when the image tag does not exist" do
      delete image_tag_path(missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end
end
