# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let(:owner) { create :user }
  let(:not_owner) { create :user }
  let(:collaborator1) { create :user }
  let(:collaborator2) { create :user }

  let(:character1) { create :character }
  let(:character2) { create :character }

  let(:location1) { create :location }
  let(:location2) { create :location }

  let!(:universe) { create :universe, name: "Milky Way", owner: owner }

  before do
    universe.collaborators << collaborator1
    universe.collaborators << collaborator2
    universe.characters << character1
    universe.characters << character2
    universe.locations << location1
    universe.locations << location2
    universe.save!
  end

  describe "GET show" do
    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator1) }

      context "when the universe is available" do
        before { get(:show, format: :json, params: { id: universe.id }) }
        subject(:universe_json) { json["universe"] }

        it "returns the universe's ID" do
          expect(universe_json["id"]).to eq(universe.id)
        end

        it "returns the universe's name" do
          expect(universe_json["name"]).to eq("Milky Way")
        end

        it "returns the universe's owner information" do
          expect(universe_json["owner"]).to eq(
            "id" => owner.id,
            "display_name" => owner.display_name,
          )
        end

        it "returns a list of the universe's collaborators" do
          expect(universe_json["collaborators"]).to match_array([
            {
              "id" => collaborator1.id,
              "display_name" => collaborator1.display_name,
            },
            {
              "id" => collaborator2.id,
              "display_name" => collaborator2.display_name,
            },
          ])
        end

        it "returns a list of the universe's characters" do
          expect(universe_json["characters"]).to match_array([
            {
              "id" => character1.id,
              "name" => character1.name,
            },
            {
              "id" => character2.id,
              "name" => character2.name,
            },
          ])
        end

        it "returns a list of the universe's locations" do
          expect(universe_json["locations"]).to match_array([
            {
              "id" => location1.id,
              "name" => location1.name,
            },
            {
              "id" => location2.id,
              "name" => location2.name,
            },
          ])
        end
      end

      context "when the universe doesn't exist" do
        before { get(:show, format: :json, params: { id: -1 }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the universe doesn't exist" do
          expect(json["errors"]).to eq([
            "No universe with ID -1 exists.",
          ])
        end
      end

      context "when the universe has been soft deleted" do
        before do
          universe.discard!
        end

        before { get(:show, format: :json, params: { id: universe.id }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the universe doesn't exist" do
          expect(json["errors"]).to eq([
            "No universe with ID #{universe.id} exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before do
        authenticate(not_owner)
        get(:show, format: :json, params: { id: universe.id })
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        expect(json["errors"]).to(
          eq(["A universe can only be viewed by its owner or collaborators."])
        )
      end
    end

    context "when the user isn't authenticated" do
      before { get(:show, format: :json, params: { id: universe.id }) }

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
