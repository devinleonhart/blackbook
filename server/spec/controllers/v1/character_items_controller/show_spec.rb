# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterItemsController, type: :controller do
  render_views

  let(:character_item) do
    create(:character_item, item: item, character: character)
  end
  let(:item) { create :item, name: "Cookies" }

  let(:character) { create :character, universe: universe }
  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET show" do
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the CharacterItem exists" do
        let(:params) { { id: character_item.id } }

        it { is_expected.to have_http_status(:success) }

        it "returns the CharacterItem's ID" do
          subject
          expect(json["character_item"]["id"]).to eq(character_item.id)
        end

        it "returns the CharacterItem's item name" do
          subject
          expect(json["character_item"]["name"]).to eq("Cookies")
        end
      end

      context "when the CharacterItem doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message indicating the CharacterItem doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No CharacterItem with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before { authenticate(create(:user)) }

      let(:params) { { id: character_item.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters' items.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: character_item.id } }

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
