# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let(:original_universe) { create :universe }
  let(:new_universe) { create :universe }

  let(:location) do
    create(
      :location,
      name: "Original Location",
      description: "Original description.",
      universe: original_universe,
    )
  end

  let(:collaborator) { create :user }

  before do
    original_universe.collaborators << collaborator
    original_universe.save!
  end

  describe "PUT/PATCH update" do
    subject { put(:update, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the location's original universe" do
      before { authenticate(collaborator) }

      context "when the location exists" do
        context "when the parameters are valid" do
          let(:params) do
            {
              id: location.id,
              location: {
                universe_id: new_universe.id,
                name: "Improved Location",
                description: "Improved description.",
              },
            }
          end

          it { is_expected.to have_http_status(:success) }

          it "updates the location's name" do
            subject
            expect(location.reload.name).to eq("Improved Location")
          end

          it "ignores any attempt to change the location's universe" do
            subject
            expect(location.reload.universe).to eq(original_universe)
          end

          it "updates the location's description" do
            subject
            expect(location.reload.description).to eq("Improved description.")
          end

          it "returns the location's ID" do
            subject
            expect(json["location"]["id"]).to eq(location.id)
          end

          it "returns the location's new name" do
            subject
            expect(json["location"]["name"]).to eq("Improved Location")
          end

          it "returns the location's new description" do
            subject
            expect(json["location"]["description"]).to(
              eq("Improved description.")
            )
          end
        end

        context "when the name parameter isn't valid" do
          let(:params) { { id: location.id, location: { name: "" } } }

          it { is_expected.to have_http_status(:bad_request) }

          it "doesn't update the location's name" do
            expect { subject }.not_to change { location.reload.name }
          end

          it "returns an error message for the invalid name" do
            subject
            expect(json["errors"]).to eq(["Name can't be blank"])
          end
        end

        context "when the description parameter isn't valid" do
          let(:params) { { id: location.id, location: { description: "" } } }

          it { is_expected.to have_http_status(:bad_request) }

          it "doesn't update the location's description" do
            expect { subject }.not_to change { location.reload.description }
          end

          it "returns an error message for the invalid description" do
            subject
            expect(json["errors"]).to eq(["Description can't be blank"])
          end
        end

        context "when an attempt is made to change the location's universe" do
          let(:params) do
            {
              id: location.id,
              location: {
                universe_id: new_universe.id,
                name: "Improved Location",
              },
            }
          end

          it { is_expected.to have_http_status(:success) }

          it "ignores any attempt to change the location's universe" do
            expect { subject }.not_to change { location.reload.universe }
          end
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
      let(:params) do
        {
          id: location.id,
          location: {
            id: -1,
            name: "Improved Location",
            description: "Improved description.",
          },
        }
      end

      before do
        authenticate(create(:user))
        put(:update, format: :json, params: params)
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{original_universe.id} to interact with its locations.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          id: location.id,
          location: {
            id: -1,
            name: "Improved Location",
            description: "Improved description.",
          },
        }
      end

      before { put(:update, format: :json, params: params) }

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
