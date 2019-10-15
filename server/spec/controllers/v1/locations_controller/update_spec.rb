# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let(:original_universe) { create :universe }
  let(:new_universe) { create :universe }
  let(:new_universe_without_collaborators) { create :universe }

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
    new_universe.collaborators << collaborator
    new_universe.save!
  end

  describe "PUT/PATCH update" do
    context "when the user is authenticated as a user with access to the location's original universe" do
      before do
        authenticate(collaborator)
      end

      context "when the location exists" do
        context "when the parameters are valid" do
          let(:params) do
            {
              id: location.id,
              location: {
                id: -1,
                universe_id: new_universe.id,
                name: "Improved Location",
                description: "Improved description.",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:location_json) { json["location"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't update the location's ID" do
            expect(location.reload.id).not_to eq(-1)
          end

          it "updates the location's name" do
            expect(location.reload.name).to eq("Improved Location")
          end

          it "updates the location's universe" do
            expect(location.reload.universe).to eq(new_universe)
          end

          it "updates the location's description" do
            expect(location.reload.description).to eq("Improved description.")
          end

          it "returns the location's ID" do
            expect(location_json["id"]).to eq(location.id)
          end

          it "returns the location's new name" do
            expect(location_json["name"]).to eq("Improved Location")
          end

          it "returns the location's new description" do
            expect(location_json["description"]).to eq("Improved description.")
          end

          it "returns the location's new universe" do
            expect(location_json["universe"]).to eq(
              "id" => new_universe.id,
              "name" => new_universe.name,
            )
          end
        end

        context "when the name parameter isn't valid" do
          let(:params) { { id: location.id, location: { name: "" } } }

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the location's name" do
            expect(location.reload.name).to eq("Original Location")
          end

          it "returns an error message for the invalid name" do
            expect(errors).to eq(["Name can't be blank"])
          end
        end

        context "when the description parameter isn't valid" do
          let(:params) { { id: location.id, location: { description: "" } } }

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the location's description" do
            expect(location.reload.description).to eq("Original description.")
          end

          it "returns an error message for the invalid description" do
            expect(errors).to eq(["Description can't be blank"])
          end
        end

        context "when the universe_id parameter isn't valid" do
          let(:params) { { id: location.id, location: { universe_id: -1 } } }

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the location's universe" do
            expect(location.reload.universe).to eq(original_universe)
          end

          it "returns an error message for the invalid universe ID" do
            expect(errors).to eq(["Universe must exist"])
          end
        end

        context "when the user doesn't have access to the new universe" do
          let(:params) do
            {
              id: location.id,
              location: { universe_id: new_universe_without_collaborators },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Forbidden status" do
            expect(response).to have_http_status(:forbidden)
          end

          it "doesn't update the location's universe" do
            expect(location.reload.universe).to eq(original_universe)
          end

          it "returns an error message stating the user doesn't have access to the universe requested" do
            expect(errors).to eq([<<~MESSAGE.squish])
              You do not have access to the universe with ID
              #{new_universe_without_collaborators.id}, which is required in
              order to move this location into that universe.
            MESSAGE
          end
        end
      end

      context "when the location doesn't exist" do
        before { put(:update, format: :json, params: { id: -1 }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      let(:params) do
        {
          id: location.id,
          location: {
            id: -1,
            universe_id: new_universe.id,
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
            universe_id: new_universe.id,
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
