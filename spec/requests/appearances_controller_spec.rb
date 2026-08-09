# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Appearances", type: :request do
  include_context "with a signed-in owner"

  let(:character) { create(:character, universe: universe) }
  let(:image) { create(:image, universe: universe) }

  describe "POST create" do
    it "creates an appearance and redirects to the image edit page" do
      expect do
        post universe_image_appearances_path(universe, image), params: { appearance: { character_id: character.id } }
      end.to change(Appearance, :count).by(1)

      expect(response).to redirect_to(edit_universe_image_url(universe, image))
    end

    it "creates appearances for several characters at once" do
      first = create(:character, universe: universe, name: "Aria")
      second = create(:character, universe: universe, name: "Bram")

      expect do
        post universe_image_appearances_path(universe, image), params: { character_ids: [first.id, second.id] }
      end.to change(Appearance, :count).by(2)

      expect(response).to redirect_to(edit_universe_image_url(universe, image))
      expect(flash[:success]).to include("2 characters")
    end

    it "skips characters already tagged or from another universe" do
      already = create(:character, universe: universe)
      create(:appearance, image: image, character: already)
      fresh = create(:character, universe: universe)
      foreign = create(:character, universe: create(:universe, owner: create(:user)))

      expect do
        post universe_image_appearances_path(universe, image),
             params: { character_ids: [already.id, fresh.id, foreign.id] }
      end.to change(Appearance, :count).by(1)

      expect(image.reload.characters).to include(fresh)
      expect(image.characters).not_to include(foreign)
    end

    it "responds with a Turbo Stream that updates both lists in place" do
      character = create(:character, universe: universe, name: "Zenith")

      post universe_image_appearances_path(universe, image),
           params: { character_ids: [character.id] },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("appearances_list", "character_picker", "Zenith")
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
    it "destroys the appearance and redirects to the image edit page" do
      appearance = create(:appearance, image: image, character: character)

      expect do
        delete appearance_path(appearance)
      end.to change(Appearance, :count).by(-1)

      expect(response).to redirect_to(edit_universe_image_url(universe, image))
    end

    it "responds with a Turbo Stream that updates both lists in place" do
      appearance = create(:appearance, image: image, character: character)

      delete appearance_path(appearance), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("appearances_list", "character_picker")
    end

    it "redirects with a flash when the appearance does not exist" do
      delete appearance_path(missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end
end
