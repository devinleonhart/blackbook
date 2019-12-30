# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::MutualRelationshipsController, type: :controller do
  render_views

  let(:mutual_relationship) do
    create(
      :mutual_relationship,
      character1: character1,
      character2: character2,
      forward_name: "Father",
      reverse_name: "Daughter",
      character_universe: universe,
    )
  end

  let(:character1) { create :character, universe: universe }
  let(:character2) { create :character, universe: universe }

  let(:universe) do
    universe = build :universe
    universe.collaborators << collaborator
    universe.save!
    universe
  end
  let(:collaborator) { create :user }

  describe "GET show" do
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the MutualRelationship exists" do
        let(:params) { { id: mutual_relationship.id } }

        it { is_expected.to have_http_status(:success) }

        it "returns data on the first character in the relationship" do
          subject
          expect(json["mutual_relationship"]["character1"]).to eq(
            "id" => character1.id,
            "name" => character1.name,
          )
        end

        it "returns data on the second character in the relationship" do
          subject
          expect(json["mutual_relationship"]["character2"]).to eq(
            "id" => character2.id,
            "name" => character2.name,
          )
        end

        it "returns the MutualRelationship's forward name" do
          subject
          expect(json["mutual_relationship"]["forward_name"]).to eq("Father")
        end

        it "returns the MutualRelationship's reverse name" do
          subject
          expect(json["mutual_relationship"]["reverse_name"]).to eq("Daughter")
        end
      end

      context "when the MutualRelationship doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message indicating the MutualRelationship doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No MutualRelationship with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before { authenticate(create(:user)) }

      let(:params) { { id: mutual_relationship.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its relationships.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: mutual_relationship.id } }

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
