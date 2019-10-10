# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let!(:location) { create :location }

  describe "DELETE delete" do
    context "when the location exists" do
      before { delete(:destroy, format: :json, params: { id: location.id }) }

      it "returns a success response" do
        expect(response).to have_http_status(:success)
      end

      it "deletes the location" do
        expect(Location.count).to be(0)
      end
    end

    context "when the location doesn't exist" do
      before { delete(:destroy, format: :json, params: { id: -1 }) }

      it "returns a Not Found Response" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
