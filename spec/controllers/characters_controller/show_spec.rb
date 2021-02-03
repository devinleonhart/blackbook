# frozen_string_literal: true

require "rails_helper"

RSpec.describe CharactersController, type: :controller do
  render_views

  let(:character) do
    create(
      :character,
      name: "Slab Bulkhead",
      description: "Tough and dense.",
      universe: universe,
    )
  end

  let!(:character_item1) { create(:character_item, character: character) }
  let!(:character_item2) { create(:character_item, character: character) }

  let!(:character_trait1) { create(:character_trait, character: character) }
  let!(:character_trait2) { create(:character_trait, character: character) }

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  let(:image) { create :image, caption: "A great pic." }
  let!(:image_tag) { create :image_tag, character: character, image: image }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET show" do
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the character exists" do
        let(:params) { { id: character.id } }

        it "returns the character's ID" do
          subject
          expect(json["character"]["id"]).to eq(character.id)
        end

        it "returns the character's name" do
          subject
          expect(json["character"]["name"]).to eq("Slab Bulkhead")
        end

        it "returns the character's description" do
          subject
          expect(json["character"]["description"]).to eq("Tough and dense.")
        end

        it "returns a list of the character's items" do
          subject
          expect(json["character"]["items"]).to match_array([
            {
              "id" => character_item1.id,
              "name" => character_item1.item.name,
            },
            {
              "id" => character_item2.id,
              "name" => character_item2.item.name,
            },
          ])
        end

        it "returns a list of the character's traits" do
          subject
          expect(json["character"]["traits"]).to match_array([
            {
              "id" => character_trait1.id,
              "name" => character_trait1.trait.name,
            },
            {
              "id" => character_trait2.id,
              "name" => character_trait2.trait.name,
            },
          ])
        end

        it "returns a list of the images the character is tagged in" do
          subject
          expect(json["character"]["image_tags"].length).to eq(1)
          image_tag_json = json["character"]["image_tags"].first
          expect(image_tag_json["image_tag_id"]).to eq(image_tag.id)
          expect(image_tag_json["image_id"]).to eq(image.id)
          expect(image_tag_json["image_caption"]).to eq("A great pic.")
          expect(image_tag_json["image_url"]).to(
            start_with("/rails/active_storage/blobs/")
          )
        end
      end

      context "when the character doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message indicating the character doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No character with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before { authenticate(create(:user)) }

      let(:params) { { id: character.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          universe_id: universe.id,
          id: character.id,
        }
      end

      it { is_expected.to have_http_status(:unauthorized) }

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
