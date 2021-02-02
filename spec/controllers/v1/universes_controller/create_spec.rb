# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let(:owner) { create :user }
  let(:collaborator1) { create :user }
  let(:collaborator2) { create :user }

  describe "POST create" do
    subject { post(:create, format: :json, params: params) }

    context "when the user has authenticated" do
      before { authenticate(owner) }

      context "when the parameters are valid" do
        let(:params) do
          {
            universe: {
              owner_id: owner.id,
              name: "Milky Way",
              collaborator_ids: [collaborator1.id, collaborator2.id],
            },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "creates the Universe" do
          expect { subject }.to change { Universe.count }.by(1)
        end

        it "sets the new universe's name" do
          subject
          expect(Universe.first.name).to eq("Milky Way")
        end

        it "sets the new universe's owner" do
          subject
          expect(Universe.first.owner).to eq(owner)
        end

        it "sets the new universe's collaborators" do
          subject
          expect(Universe.first.collaborators).to match_array(
            [collaborator1, collaborator2]
          )
        end

        it "returns the new universe's ID" do
          subject
          expect(json["universe"]["id"]).to eq(Universe.first.id)
        end

        it "returns the new universe's name" do
          subject
          expect(json["universe"]["name"]).to eq("Milky Way")
        end

        it "returns the new universe's owner's information" do
          subject
          expect(json["universe"]["owner"]).to eq(
            "id" => owner.id,
            "display_name" => owner.display_name,
          )
        end

        it "returns a list of the new universe's collaborators" do
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
          expect(json["universe"]["characters"]).to eq([])
        end

        it "returns a list of the universe's locations" do
          subject
          expect(json["universe"]["locations"]).to eq([])
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

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the universe" do
          expect { subject }.not_to change { Universe.count }
        end

        it "returns an error message for the invalid name" do
          subject
          expect(json["errors"]).to eq(["Name can't be blank"])
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

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the universe" do
          expect { subject }.not_to change { Universe.count }
        end

        it "returns an error message for the invalid owner ID" do
          subject
          expect(json["errors"]).to eq(["Owner must exist"])
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

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the universe" do
          expect { subject }.not_to change { Universe.count }
        end

        it "returns an error message for the invalid collaborator ID" do
          subject
          expect(json["errors"]).to eq(["No User with ID [-1] exists."])
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

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't create a new Universe" do
        expect { subject }.not_to change { Universe.count }
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
