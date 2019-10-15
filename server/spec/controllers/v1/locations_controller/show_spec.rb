# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let(:location) do
    create(
      :location,
      name: "Store",
      description: "Good deals here.",
      universe: universe,
    )
  end

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET show" do
    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the location exists" do
        let(:params) do
          {
            universe_id: universe.id,
            id: location.id,
          }
        end

        before { get(:show, format: :json, params: params) }
        subject(:location_json) { json["location"] }

        it "returns the location's ID" do
          expect(location_json["id"]).to eq(location.id)
        end

        it "returns the location's name" do
          expect(location_json["name"]).to eq("Store")
        end

        it "returns the location's description" do
          expect(location_json["description"]).to eq("Good deals here.")
        end

        it "returns the location's universe's information" do
          expect(location_json["universe"]).to eq(
            "id" => universe.id,
            "name" => universe.name,
          )
        end
      end

      context "when the location doesn't exist" do
        let(:params) do
          {
            universe_id: universe.id,
            id: -1,
          }
        end

        before { get(:show, format: :json, params: params) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the location doesn't exist" do
          expect(json["errors"]).to eq([
            "No location with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      let(:params) do
        {
          universe_id: universe.id,
          id: location.id,
        }
      end

      before do
        authenticate(create(:user))
        get(:show, format: :json, params: params)

        it "returns a forbidden HTTP status code" do
          expect(response).to have_http_status(:forbidden)
        end

        it "returns an error message indicating only the owner or a collaborator can view the universe" do
          expect(json["errors"]).to(
            eq([<<~MESSAGE.strip])
              You must be an owner or collaborator for the universe with ID
              #{universe.id} to interact with its locations.
            MESSAGE
          )
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          universe_id: universe.id,
          id: location.id,
        }
      end

      before { get(:show, format: :json, params: params) }

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
