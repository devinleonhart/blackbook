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

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET show" do
    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the MutualRelationship exists" do
        before do
          get(:show, format: :json, params: { id: mutual_relationship.id })
        end
        subject(:mutual_relationship_json) { json["mutual_relationship"] }

        it "returns the MutualRelationship's ID" do
          expect(mutual_relationship_json["id"]).to eq(mutual_relationship.id)
        end

        it "returns data on the first character in the relationship" do
          expect(mutual_relationship_json["character1"]).to eq(
            "id" => character1.id,
            "name" => character1.name,
          )
        end

        it "returns data on the second character in the relationship" do
          expect(mutual_relationship_json["character2"]).to eq(
            "id" => character2.id,
            "name" => character2.name,
          )
        end

        it "returns the MutualRelationship's forward name" do
          expect(mutual_relationship_json["forward_name"]).to eq("Father")
        end

        it "returns the MutualRelationship's reverse name" do
          expect(mutual_relationship_json["reverse_name"]).to eq("Daughter")
        end
      end

      context "when the MutualRelationship doesn't exist" do
        before { get(:show, format: :json, params: { id: -1 }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the MutualRelationship doesn't exist" do
          expect(json["errors"]).to eq([
            "No MutualRelationship with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before do
        authenticate(create(:user))
        get(:show, format: :json, params: { id: mutual_relationship.id })

        it "returns a forbidden HTTP status code" do
          expect(response).to have_http_status(:forbidden)
        end

        it "returns an error message indicating only the owner or a collaborator can view the universe" do
          expect(json["errors"]).to(
            eq([<<~MESSAGE.strip])
              You must be an owner or collaborator for the universe with ID
              #{universe.id} to interact with its relationships.
            MESSAGE
          )
        end
      end
    end

    context "when the user isn't authenticated" do
      before do
        get(:show, format: :json, params: { id: mutual_relationship.id })
      end

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
