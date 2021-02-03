# frozen_string_literal: true

require "rails_helper"

RSpec.describe CharactersController, type: :controller do
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
            character: {
              name: "Juliet Cannell",
              description: "Happy-go-lucky.",
            },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "creates the character" do
          expect { subject }.to change { Character.count }.by(1)
        end

        it "sets the new character's name" do
          subject
          expect(Character.first.name).to eq("Juliet Cannell")
        end

        it "sets the new character's description" do
          subject
          expect(Character.first.description).to eq("Happy-go-lucky.")
        end

        it "returns the new character's ID" do
          subject
          expect(json["character"]["id"]).to eq(Character.first.id)
        end

        it "returns the new character's name" do
          subject
          expect(json["character"]["name"]).to eq("Juliet Cannell")
        end

        it "returns the new character's description" do
          subject
          expect(json["character"]["description"]).to(
            eq("Happy-go-lucky.")
          )
        end

        it "returns an empty items list" do
          subject
          expect(json["character"]["items"]).to eq([])
        end

        it "returns an empty traits list" do
          subject
          expect(json["character"]["traits"]).to eq([])
        end

        it "returns an empty image tags list" do
          subject
          expect(json["character"]["image_tags"]).to eq([])
        end
      end

      context "when the name parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character: {
              name: "",
              description: "Happy-go-lucky.",
            },
          }
        end

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the character" do
          expect { subject }.not_to change { Character.count }
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
            character: {
              name: "Juliet Cannell",
              description: "",
            },
          }
        end

        it { is_expected.to have_http_status(:bad_request) }

        it "doesn't create the character" do
          expect { subject }.not_to change { Character.count }
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
            character: {
              name: "Juliet Cannell",
              description: "Happy-go-lucky.",
            },
          }
        end

        it { is_expected.to have_http_status(:not_found) }

        it "doesn't create the character" do
          subject
          expect { subject }.not_to change { Character.count }
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
          character: {
            name: "Juliet Cannell",
            description: "Happy-go-lucky.",
          },
        }
      end

      before do
        authenticate(not_owner)
      end

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't create a new Character" do
        expect { subject }.not_to change { Character.count }
      end

      it "returns an error message informing the user they don't have access" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          universe_id: universe.id,
          character: {
            name: "Juliet Cannell",
            description: "Happy-go-lucky.",
          },
        }
      end

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't create a new Character" do
        expect { subject }.not_to change { Character.count }
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
