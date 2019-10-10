# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let(:universe) { create :universe }

  describe "POST create" do
    context "when the parameters are valid" do
      let(:params) do
        {
          universe_id: universe.id,
          location: {
            id: -1,
            name: "Home",
            description: "Is where the heart is.",
          },
        }
      end

      before { post(:create, format: :json, params: params) }
      subject(:location) { Location.first }
      subject(:location_json) { json["location"] }

      it "returns a successful HTTP status code" do
        expect(response).to have_http_status(:success)
      end

      it "ignores the id parameter" do
        expect(location.id).not_to eq(-1)
      end

      it "sets the new location's name" do
        expect(location.name).to eq("Home")
      end

      it "sets the new location's description" do
        expect(location.description).to eq("Is where the heart is.")
      end

      it "returns the new location's ID" do
        expect(location_json["id"]).to eq(location.id)
      end

      it "returns the new location's name" do
        expect(location_json["name"]).to eq("Home")
      end

      it "returns the new location's description" do
        expect(location_json["description"]).to eq("Is where the heart is.")
      end
    end

    context "when the name parameter isn't valid" do
      let(:params) do
        {
          universe_id: universe.id,
          location: {
            name: "",
            description: "Is where the heart is.",
          },
        }
      end

      before { post(:create, format: :json, params: params) }
      subject(:location) { Location.first }
      subject(:errors) { json["errors"] }

      it "returns a Bad Request status" do
        expect(response).to have_http_status(:bad_request)
      end

      it "doesn't create the location" do
        expect(location).to be_nil
      end

      it "returns an error message for the invalid name" do
        expect(errors).to eq(["Name can't be blank"])
      end
    end

    context "when the description parameter isn't valid" do
      let(:params) do
        {
          universe_id: universe.id,
          location: {
            name: "Home",
            description: "",
          },
        }
      end

      before { post(:create, format: :json, params: params) }
      subject(:location) { Location.first }
      subject(:errors) { json["errors"] }

      it "returns a Bad Request status" do
        expect(response).to have_http_status(:bad_request)
      end

      it "doesn't create the location" do
        expect(location).to be_nil
      end

      it "returns an error message for the invalid name" do
        expect(errors).to eq(["Description can't be blank"])
      end
    end

    context "when the universe_id parameter isn't valid" do
      let(:params) do
        {
          universe_id: -1,
          location: {
            name: "Home",
            description: "Is where the heart is.",
          },
        }
      end

      before { post(:create, format: :json, params: params) }
      subject(:location) { Location.first }
      subject(:errors) { json["errors"] }

      it "returns a Bad Request status" do
        expect(response).to have_http_status(:bad_request)
      end

      it "doesn't create the location" do
        expect(location).to be_nil
      end

      it "returns an error message for the invalid name" do
        expect(errors).to eq(["Universe must exist"])
      end
    end
  end
end
