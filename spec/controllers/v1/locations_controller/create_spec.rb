# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let(:universe) { create :universe, owner: owner }
  let(:owner) { create :user }
  let(:not_owner) { create :user }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "POST create" do
    subject { post(:create, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the parameters are valid" do
        let(:params) do
          {
            universe_id: universe.id,
            location: {
              name: "Home",
              description: "Is where the heart is.",
            },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "creates a new Location" do
          expect { subject }.to change { Location.count }.by(1)
        end

        it "sets the new location's name" do
          subject
          expect(Location.first.name).to eq("Home")
        end

        it "sets the new location's description" do
          subject
          expect(Location.first.description).to eq("Is where the heart is.")
        end

        it "returns the new location's ID" do
          subject
          expect(json["location"]["id"]).to eq(Location.first.id)
        end

        it "returns the new location's name" do
          subject
          expect(json["location"]["name"]).to eq("Home")
        end

        it "returns the new location's description" do
          subject
          expect(json["location"]["description"]).to(
            eq("Is where the heart is.")
          )
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

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the location" do
          expect { subject }.not_to change { Location.count }
        end

        it "returns an error message for the invalid name" do
          subject
          expect(json["errors"]).to eq(["Name can't be blank"])
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

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the location" do
          expect { subject }.not_to change { Location.count }
        end

        it "returns an error message for the invalid name" do
          subject
          expect(json["errors"]).to eq(["Description can't be blank"])
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

        it { is_expected.to have_http_status(:not_found) }

        it "doesn't create the location" do
          expect { subject }.not_to change { Location.count }
        end

        it "returns an error message for the invalid universe ID" do
          subject
          expect(json["errors"]).to eq(["No universe with ID -1 exists."])
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      let(:params) do
        {
          universe_id: universe.id,
          location: {
            name: "Home",
            description: "Is where the heart is.",
          },
        }
      end

      before { authenticate(not_owner) }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't create a new Location" do
        expect { subject }.not_to change { Location.count }
      end

      it "returns an error message informing the user they don't have access" do
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
      let(:params) do
        {
          universe_id: universe.id,
          location: {
            name: "Home",
            description: "Is where the heart is.",
          },
        }
      end

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't create a new Location" do
        expect { subject }.not_to change { Location.count }
      end

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
