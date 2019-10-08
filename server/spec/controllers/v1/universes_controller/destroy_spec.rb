# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let!(:universe) { create :universe }

  describe "DELETE delete" do
    context "when the universe is available" do
      before { delete(:destroy, format: :json, params: { id: universe.id }) }

      it "returns a success response" do
        expect(response).to have_http_status(:success)
      end

      it "soft deletes the universe" do
        expect(universe.reload.discarded?).to be(true)
      end
    end

    context "when the universe is already deleted" do
      before do
        universe.discard!
      end

      before { delete(:destroy, format: :json, params: { id: universe.id }) }

      it "is idempotent" do
        expect(response).to have_http_status(:success)
        expect(universe.reload.discarded?).to be(true)
      end
    end

    context "when the universe doesn't exist" do
      before { delete(:destroy, format: :json, params: { id: -1 }) }

      it "returns a Not Found Response" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
