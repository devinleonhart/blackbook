# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let(:owner) { create :user }
  let(:collaborator1) { create :user }
  let(:collaborator2) { create :user }

  describe "POST create" do
    context "when the user has authenticated" do
      before { authenticate(owner) }

      context "when the parameters are valid" do
        let(:params) do
          {
            universe: {
              id: -1,
              owner_id: owner.id,
              name: "Milky Way",
              collaborator_ids: [collaborator1.id, collaborator2.id],
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:universe) { Universe.first }
        subject(:universe_json) { json["universe"] }

        it "returns a successful HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "ignores the id parameter" do
          expect(universe.id).not_to eq(-1)
        end

        it "sets the new universe's name" do
          expect(universe.name).to eq("Milky Way")
        end

        it "sets the new universe's owner" do
          expect(universe.owner).to eq(owner)
        end

        it "sets the new universe's collaborators" do
          expect(universe.collaborators).to match_array(
            [collaborator1, collaborator2]
          )
        end

        it "returns the new universe's ID" do
          expect(universe_json["id"]).to eq(universe.id)
        end

        it "returns the new universe's name" do
          expect(universe_json["name"]).to eq("Milky Way")
        end

        it "returns the new universe's owner's information" do
          expect(universe_json["owner"]).to eq(
            "id" => owner.id,
            "display_name" => owner.display_name,
          )
        end

        it "returns a list of the new universe's collaborators" do
          expect(universe_json["collaborators"]).to match_array([
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
          expect(universe_json["characters"]).to eq([])
        end

        it "returns a list of the universe's locations" do
          expect(universe_json["locations"]).to eq([])
        end
      end

      context "when the name parameter isn't valid" do
        let(:params) do
          {
            universe: {
              owner_id: owner.id,
              name: "",
              collaborator_ids: [collaborator1.id, collaborator2.id],
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:universe) { Universe.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the universe" do
          expect(universe).to be_nil
        end

        it "returns an error message for the invalid name" do
          expect(errors).to eq(["Name can't be blank"])
        end
      end

      context "when the owner_id parameter isn't valid" do
        let(:params) do
          {
            universe: {
              owner_id: -1,
              name: "Milky Way",
              collaborator_ids: [collaborator1.id, collaborator2.id],
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:universe) { Universe.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the universe" do
          expect(universe).to be_nil
        end

        it "returns an error message for the invalid owner ID" do
          expect(errors).to eq(["Owner must exist"])
        end
      end

      context "when the collaborator_ids parameter isn't valid" do
        let(:params) do
          {
            universe: {
              owner_id: owner.id,
              name: "Milky Way",
              collaborator_ids: [-1],
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:universe) { Universe.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the universe" do
          expect(universe).to be_nil
        end

        it "returns an error message for the invalid collaborator ID" do
          expect(errors).to eq(["No User with ID [-1] exists."])
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          universe: {
            id: -1,
            owner_id: owner.id,
            name: "Milky Way",
            collaborator_ids: [collaborator1.id, collaborator2.id],
          },
        }
      end

      before { post(:create, format: :json, params: params) }

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create a new Universe" do
        expect(Universe.count).to eq(0)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
