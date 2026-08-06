# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Universes", type: :request do
  include_context "with a signed-in owner"

  describe "GET index" do
    it "lists owned and collaborated universes" do
      owned = create(:universe, owner: owner, name: "Owned U")
      collaborated = create(:universe, owner: create(:user), name: "Collab U")
      create(:collaboration, universe: collaborated, user: owner)

      get universes_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(owned.name, collaborated.name)
    end
  end

  describe "GET show" do
    it "renders the universe with its images and tag browser" do
      character = create(:character, universe: universe)
      image = create(:image, universe: universe)
      create(:image_tag, image: image, character: character)
      create(:character_tag, character: character, name: "hero")

      get universe_path(universe)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("hero")
    end

    it "supports the untagged filter" do
      character = create(:character, universe: universe)
      tagged = create(:image, universe: universe)
      create(:image_tag, image: tagged, character: character)
      create(:image, universe: universe)

      get universe_path(universe, filter: "untagged")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Untagged Images")
    end

    it "redirects with a flash when the universe does not exist" do
      get universe_path(missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end

    it "redirects a user who cannot access the universe" do
      stranger_universe = create(:universe, owner: create(:user))

      get universe_path(stranger_universe)

      expect(response).to redirect_to(universes_url)
    end
  end

  describe "GET new" do
    it "renders the new-universe form" do
      get new_universe_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET edit" do
    it "renders the edit form" do
      get edit_universe_path(universe)

      expect(response).to have_http_status(:ok)
    end

    it "redirects with a flash when the universe does not exist" do
      get edit_universe_path(missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end

  describe "POST create" do
    context "with valid params" do
      it "creates the universe and redirects to the index" do
        expect do
          post universes_path, params: { universe: { name: "New Universe" } }
        end.to change { Universe.where(owner: owner).count }.by(1)

        expect(response).to redirect_to(universes_url)
      end
    end

    context "with invalid params" do
      it "does not create and redirects back to new" do
        expect do
          post universes_path, params: { universe: { name: "" } }
        end.not_to change(Universe, :count)

        expect(response).to redirect_to(new_universe_url)
      end
    end
  end

  describe "PATCH update" do
    context "with valid params" do
      it "updates the universe for a collaborator" do
        collaborator = create(:user)
        target = create(:universe, owner: create(:user), name: "Old")
        create(:collaboration, universe: target, user: collaborator)

        sign_in(collaborator)
        patch universe_path(target), params: { universe: { name: "Updated" } }

        expect(response).to redirect_to(universes_url)
        expect(target.reload.name).to eq("Updated")
      end
    end

    context "with invalid params" do
      it "does not update and redirects back to edit with a flash" do
        patch universe_path(universe), params: { universe: { name: "" } }

        expect(response).to redirect_to(edit_universe_url(universe))
        expect(flash[:error]).to be_present
      end
    end
  end
end
