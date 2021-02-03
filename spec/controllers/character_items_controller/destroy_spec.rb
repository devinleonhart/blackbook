# frozen_string_literal: true

require "rails_helper"

RSpec.describe CharacterItemsController, type: :controller do
  render_views

  let!(:character_item) { create :character_item, character: character }

  let(:character) { create :character, universe: universe }
  let(:universe) do
    universe = build(:universe, owner: owner)
    universe.collaborators << collaborator
    universe.save!
    universe
  end
  let(:owner) { create :user }
  let(:collaborator) { create :user }
  let(:not_owner) { create :user }

  describe "DELETE destroy" do
    subject { delete(:destroy, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the CharacterItem exists" do
        let(:params) { { id: character_item.id } }

        it { is_expected.to have_http_status(:success) }

        it "deletes the CharacterItem" do
          expect { subject }.to change { CharacterItem.count }.by(-1)
        end
      end

      context "when the CharacterItem doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message informing the user the resource doesn't exist" do
          subject
          expect(json["errors"]).to eq(["No CharacterItem with ID -1 exists."])
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      before { authenticate(not_owner) }

      let(:params) { { id: character_item.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't delete the CharacterItem" do
        expect { subject }.not_to change { CharacterItem.count }
      end

      it "returns an error message informing the user they don't have access" do
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

      it "doesn't delete the CharacterItem" do
        expect { subject }.not_to change { CharacterItem.count }
      end

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
