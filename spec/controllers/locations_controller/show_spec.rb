# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocationsController, type: :controller do
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
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "when the location exists" do
        let(:params) { { id: location.id } }

        it "returns the location's ID" do
          subject
          expect(json["location"]["id"]).to eq(location.id)
        end

        it "returns the location's name" do
          subject
          expect(json["location"]["name"]).to eq("Store")
        end

        it "returns the location's description" do
          subject
          expect(json["location"]["description"]).to eq("Good deals here.")
        end
      end

      context "when the location doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message indicating the location doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No location with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before { authenticate(create(:user)) }

      let(:params) { { id: location.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its locations.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: location.id } }

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
