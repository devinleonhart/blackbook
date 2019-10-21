# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let(:original_owner) { create :user }
  let(:new_owner) { create :user }
  let(:not_owner) { create :user }
  let(:original_collaborator) { create :user }
  let(:new_collaborator1) { create :user }
  let(:new_collaborator2) { create :user }

  let(:character1) { create :character }
  let(:character2) { create :character }

  let(:location1) { create :location }
  let(:location2) { create :location }

  let!(:universe) { create :universe, name: "Milky Way", owner: original_owner }

  before do
    universe.collaborators << original_collaborator
    universe.characters << character1
    universe.characters << character2
    universe.locations << location1
    universe.locations << location2
    universe.save!
  end

  describe "PUT/PATCH update" do
    context "when the user is authenticated as the universe's original owner" do
      before { authenticate(original_owner) }

      context "when the universe exists" do
        context "when the parameters are valid" do
          let(:params) do
            {
              id: universe.id,
              universe: {
                id: -1,
                owner_id: new_owner.id,
                name: "Andromeda",
                collaborator_ids: [new_collaborator1.id, new_collaborator2.id],
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:universe_json) { json["universe"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't update the universe's ID" do
            expect(universe.reload.id).not_to eq(-1)
          end

          it "updates the universe's name" do
            expect(universe.reload.name).to eq("Andromeda")
          end

          it "updates the universe's owner" do
            expect(universe.reload.owner).to eq(new_owner)
          end

          it "updates the universe's collaborators" do
            expect(universe.reload.collaborators).to(
              match_array([new_collaborator1, new_collaborator2])
            )
          end

          it "returns the universe's ID" do
            expect(universe_json["id"]).to eq(universe.id)
          end

          it "returns the universe's new name" do
            expect(universe_json["name"]).to eq("Andromeda")
          end

          it "returns the universe's new owner's information" do
            expect(universe_json["owner"]).to eq(
              "id" => new_owner.id,
              "display_name" => new_owner.display_name,
            )
          end

          it "returns a list of the universe's new collaborators" do
            expect(universe_json["collaborators"]).to eq([
              {
                "id" => new_collaborator1.id,
                "display_name" => new_collaborator1.display_name,
              },
              {
                "id" => new_collaborator2.id,
                "display_name" => new_collaborator2.display_name,
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

        context "when the collaborator IDs are empty" do
          let(:params) do
            {
              id: universe.id,
              universe: {
                name: "Andromeda",
                collaborator_ids: [],
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:universe_json) { json["universe"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't update the universe's collaborators" do
            expect(universe.reload.collaborators).to(
              eq([original_collaborator])
            )
          end

          it "returns a list of the universe's previous collaborators" do
            expect(universe_json["collaborators"]).to eq([
              {
                "id" => original_collaborator.id,
                "display_name" => original_collaborator.display_name,
              },
            ])
          end
        end

        context "when the non-association parameters are invalid" do
          let(:params) do
            {
              id: universe.id,
              universe: {
                name: "",
                owner_id: -1,
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the universe's name" do
            expect(universe.reload.name).to eq("Milky Way")
          end

          it "returns an error message for the invalid name" do
            expect(errors).to match_array([
              "Name can't be blank",
              "Owner must exist",
            ])
          end
        end

        context "when the collaborator_ids parameter isn't valid" do
          let(:params) do
            { id: universe.id, universe: { collaborator_ids: [-1] } }
          end

          before { put(:update, format: :json, params: params) }
          subject(:errors) { json["errors"] }

          it "returns a Bad Request status" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the universe's collaborators" do
            expect(universe.reload.collaborators).to eq([original_collaborator])
          end

          it "returns an error message for the invalid collaborator ID" do
            expect(errors).to eq(["No User with ID [-1] exists."])
          end
        end
      end

      context "when the universe doesn't exist" do
        before { put(:update, format: :json, params: { id: -1 }) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the universe has been soft deleted" do
        let(:params) do
          {
            id: universe.id,
            universe: {
              id: -1,
              owner_id: new_owner.id,
              name: "Andromeda",
              collaborator_ids: [new_collaborator1.id, new_collaborator2.id],
            },
          }
        end

        before { universe.discard! }
        before { put(:update, format: :json, params: params) }

        it "responds with a Not Found HTTP status code" do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the user is authenticated as a current collaborator on the universe" do
      let(:params) do
        {
          id: universe.id,
          universe: {
            id: -1,
            owner_id: new_owner.id,
            name: "Andromeda",
            collaborator_ids: [new_collaborator1.id, new_collaborator2.id],
          },
        }
      end

      before do
        authenticate(original_collaborator)
        put(:update, format: :json, params: params)
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating only the owner can change the universe" do
        expect(json["errors"]).to(
          eq(["A universe can only be changed by its owner."])
        )
      end
    end

    context "when the user is authenticated as a user unrelated to the universe" do
      let(:params) do
        {
          id: universe.id,
          universe: {
            id: -1,
            owner_id: new_owner.id,
            name: "Andromeda",
            collaborator_ids: [new_collaborator1.id, new_collaborator2.id],
          },
        }
      end

      before do
        authenticate(not_owner)
        put(:update, format: :json, params: params)
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating only the owner can change the universe" do
        expect(json["errors"]).to(
          eq(["A universe can only be changed by its owner."])
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          id: universe.id,
          universe: {
            id: -1,
            owner_id: new_owner.id,
            name: "Andromeda",
            collaborator_ids: [new_collaborator1.id, new_collaborator2.id],
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
