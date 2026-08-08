# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Slideshow", type: :request do
  describe "GET show" do
    it "redirects unauthenticated users to sign in" do
      get slideshow_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders the slideshow page for authenticated users" do
      sign_in(create(:user))

      get slideshow_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Slideshow")
    end

    context "with a universe selected" do
      include_context "with a signed-in owner"

      it "renders the trait picker for that universe" do
        create(:image, universe: universe)
        character = create(:character, universe: universe, name: "Aria")
        create(:trait, character: character, name: "villain")

        get slideshow_path(universe_id: universe.id)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Traits:")
        expect(response.body).to include("villain")
      end
    end
  end

  describe "GET images" do
    include_context "with a signed-in owner"

    def slides
      response.parsed_body.fetch("slides")
    end

    def slide_ids
      slides.map { |slide| slide.fetch("id") }
    end

    it "redirects unauthenticated users to sign in" do
      sign_out(owner)

      get slideshow_images_path(mode: "all")

      expect(response).to redirect_to(new_user_session_path)
    end

    context "with mode=all" do
      it "returns only images the user can access" do
        accessible = create(:image, universe: universe)
        inaccessible = create(:image, universe: create(:universe, owner: create(:user)))

        get slideshow_images_path(mode: "all")

        expect(response).to have_http_status(:ok)
        expect(slide_ids).to include(accessible.id)
        expect(slide_ids).not_to include(inaccessible.id)
      end

      it "filters slides to a specific accessible universe" do
        other_universe = create(:universe, owner: owner)
        included = create(:image, universe: universe)
        excluded = create(:image, universe: other_universe)

        get slideshow_images_path(mode: "all", universe_id: universe.id)

        expect(slide_ids).to include(included.id)
        expect(slide_ids).not_to include(excluded.id)
      end

      it "returns 404 when filtering to an inaccessible universe" do
        inaccessible = create(:universe, owner: create(:user))
        create(:image, universe: inaccessible)

        get slideshow_images_path(mode: "all", universe_id: inaccessible.id)

        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for a non-numeric universe id" do
        get slideshow_images_path(mode: "all", universe_id: "not-a-number")

        expect(response).to have_http_status(:not_found)
      end
    end

    context "with the default slide payload" do
      it "includes detail/favorite urls, favorite state, and character names" do
        image = create(:image, universe: universe)
        character = create(:character, universe: universe, name: "Zara")
        create(:appearance, image: image, character: character)
        create(:image_favorite, user: owner, image: image)

        get slideshow_images_path(mode: "all", universe_id: universe.id)

        slide = slides.find { |s| s.fetch("id") == image.id }
        expect(slide.fetch("detail_url")).to eq(edit_universe_image_path(universe.id, image.id))
        expect(slide.fetch("favorite_url")).to eq(universe_image_path(universe.id, image.id))
        expect(slide.fetch("favorited")).to be(true)
        expect(slide.fetch("characters")).to eq(["Zara"])
      end

      it "reports favorited: false for images the user has not favorited" do
        image = create(:image, universe: universe)

        get slideshow_images_path(mode: "all", universe_id: universe.id)

        slide = slides.find { |s| s.fetch("id") == image.id }
        expect(slide.fetch("favorited")).to be(false)
      end
    end

    context "with a trait filter" do
      it "returns only images featuring a character with the selected trait" do
        matching = create(:image, universe: universe)
        non_matching = create(:image, universe: universe)
        villain = create(:character, universe: universe)
        create(:trait, character: villain, name: "villain")
        create(:appearance, image: matching, character: villain)

        get slideshow_images_path(mode: "all", universe_id: universe.id, trait_names: ["villain"])

        expect(slide_ids).to include(matching.id)
        expect(slide_ids).not_to include(non_matching.id)
      end

      it "matches trait names case-insensitively (they are stored normalized)" do
        image = create(:image, universe: universe)
        character = create(:character, universe: universe)
        create(:trait, character: character, name: "mentor")
        create(:appearance, image: image, character: character)

        get slideshow_images_path(mode: "all", universe_id: universe.id, trait_names: ["  MENTOR  "])

        expect(slide_ids).to include(image.id)
      end

      it "ignores blank trait names" do
        image = create(:image, universe: universe)

        get slideshow_images_path(mode: "all", universe_id: universe.id, trait_names: [""])

        expect(slide_ids).to include(image.id)
      end
    end

    context "with mode=favorites" do
      it "returns only the current user's favorites, still enforcing universe access" do
        favorited_accessible = create(:image, universe: universe)
        not_favorited = create(:image, universe: universe)
        inaccessible_universe = create(:universe, owner: create(:user))
        favorited_inaccessible = create(:image, universe: inaccessible_universe)

        create(:image_favorite, user: owner, image: favorited_accessible)
        create(:image_favorite, user: owner, image: favorited_inaccessible)
        create(:image_favorite, user: create(:user), image: favorited_accessible)

        get slideshow_images_path(mode: "favorites")

        expect(response).to have_http_status(:ok)
        expect(slide_ids).to include(favorited_accessible.id)
        expect(slide_ids).not_to include(not_favorited.id, favorited_inaccessible.id)
      end
    end
  end
end
