# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let(:owner) { create :user }
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
          "name" => owner.name,
        )
      end

      it "returns a list of the universe's collaborators" do
        expect(universe_json["collaborators"]).to eq([
          {
            "id" => collaborator1.id,
            "name" => collaborator1.name,
          },
          {
            "id" => collaborator2.id,
            "name" => collaborator2.name,
          },
        ])
      end

      it "returns a list of the universe's characters" do
        expect(universe_json["characters"]).to eq([
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
        expect(universe_json["locations"]).to eq([
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
    end

    context "when the universe has been soft deleted" do
      before do
        universe.discard!
      end

      before { get(:show, format: :json, params: { id: universe.id }) }

      it "responds with a Not Found HTTP status code" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
