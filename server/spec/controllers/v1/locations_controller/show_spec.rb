# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let(:universe) { create :universe }

  let(:location) do
    create(
      :location,
      name: "Store",
      description: "Good deals here.",
      universe: universe,
    )
  end

  describe "GET show" do
    context "when the location exists" do
      before { get(:show, format: :json, params: { id: location.id }) }
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
      before { get(:show, format: :json, params: { id: -1 }) }

      it "responds with a Not Found HTTP status code" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
