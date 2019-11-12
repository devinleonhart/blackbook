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
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator1) }

      context "when the universe is available" do
        let(:params) { { id: universe.id } }

        it "returns the universe's ID" do
          subject
          expect(json["universe"]["id"]).to eq(universe.id)
        end

        it "returns the universe's name" do
          subject
          expect(json["universe"]["name"]).to eq("Milky Way")
        end

        it "returns the universe's owner information" do
          subject
          expect(json["universe"]["owner"]).to eq(
            "id" => owner.id,
            "display_name" => owner.display_name,
          )
        end

        it "returns a list of the universe's collaborators" do
          subject
          expect(json["universe"]["collaborators"]).to match_array([
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
          subject
          expect(json["universe"]["characters"]).to match_array([
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
          subject
          expect(json["universe"]["locations"]).to match_array([
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
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message indicating the universe doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No universe with ID -1 exists.",
          ])
        end
      end

      context "when the universe has been soft deleted" do
        before do
          universe.discard!
        end

        let(:params) { { id: universe.id } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message indicating the universe doesn't exist" do
          subject
          expect(json["errors"]).to eq([
            "No universe with ID #{universe.id} exists.",
          ])
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before do
        authenticate(not_owner)
      end

      let(:params) { { id: universe.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        subject
        expect(json["errors"]).to(
          eq(["A universe can only be viewed by its owner or collaborators."])
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: universe.id } }

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
