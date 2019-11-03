# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::MutualRelationshipsController, type: :controller do
  render_views

  let!(:mutual_relationship1) do
    create(
      :mutual_relationship,
      character1: character1,
      character2: character2,
      forward_name: "Father",
      reverse_name: "Daughter",
      character_universe: universe,
    )
  end
  let!(:mutual_relationship2) do
    create(
      :mutual_relationship,
      character1: character1,
      character2: character2,
      forward_name: "Mentor",
      reverse_name: "Student",
      character_universe: universe,
    )
  end
  let!(:mutual_relationship3) do
    create(
      :mutual_relationship,
      character1: character2,
      character2: character1,
      forward_name: "Secret Santa gift-giver",
      reverse_name: "Secret Santa gift-recipient",
      character_universe: universe,
    )
  end
  let!(:mutual_relationship4) do
    create(
      :mutual_relationship,
      character1: character1,
      character2: character3,
      forward_name: "Father",
      reverse_name: "Daughter",
      character_universe: universe,
    )
  end
  let!(:mutual_relationship5) do
    create(
      :mutual_relationship,
      character1: character2,
      character2: character3,
      forward_name: "Sister",
      reverse_name: "Sister",
      character_universe: universe,
    )
  end

  let(:character1) { create :character, universe: universe }
  let(:character2) { create :character, universe: universe }
  let(:character3) { create :character, universe: universe }

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET index" do
    subject do
      get(
        :index,
        format: :json,
        params: params,
      )
    end

    context "when the user is authenticated as a user with access to the universe" do
      before do
        authenticate(collaborator)
      end

      context "and the characters are in that universe" do
        let(:params) do
          { universe_id: universe.id, character_id: character1.id }
        end

        it "returns the first relationship from character1 to character2" do
          subject
          relationship = {
            "id" => mutual_relationship1.id,
            "name" => "Father",
            "target_character" => {
              "id" => character2.id,
              "name" => character2.name,
            },
          }
          expect(json).to include(relationship)
        end

        it "returns the second relationship from character1 to character2" do
          subject
          relationship = {
            "id" => mutual_relationship2.id,
            "name" => "Mentor",
            "target_character" => {
              "id" => character2.id,
              "name" => character2.name,
            },
          }
          expect(json).to include(relationship)
        end

        it "returns the third relationship from character1 to character2" do
          subject
          relationship = {
            "id" => mutual_relationship3.id,
            "name" => "Secret Santa gift-recipient",
            "target_character" => {
              "id" => character2.id,
              "name" => character2.name,
            },
          }
          expect(json).to include(relationship)
        end

        it "returns the first relationship from character1 to character3" do
          subject
          relationship = {
            "id" => mutual_relationship4.id,
            "name" => "Father",
            "target_character" => {
              "id" => character3.id,
              "name" => character3.name,
            },
          }
          expect(json).to include(relationship)
        end

        it "returns only the three relevant relationships" do
          subject
          expect(json.length).to eq(4)
        end
      end

      context "and the requested characters aren't in that universe" do
        let(:non_universe_character) { create :character }

        let(:params) do
          { universe_id: universe.id, character_id: non_universe_character.id }
        end

        it "returns a Bad Request status" do
          subject
          expect(response).to have_http_status(:bad_request)
        end

        it "returns an error message for the character not belonging to the universe" do
          subject
          expect(json["errors"]).to eq([<<~ERROR_MESSAGE.squish])
            Character with ID #{non_universe_character.id} does not belong to
            Universe #{universe.id}.
          ERROR_MESSAGE
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the universe" do
      before do
        authenticate(create(:user))
      end

      let(:params) do
        { universe_id: universe.id, character_id: character1.id }
      end

      it "returns a forbidden HTTP status code" do
        subject
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating this user can't interact with the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its relationships.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        { universe_id: universe.id, character_id: character1.id }
      end

      it "returns a forbidden HTTP status code" do
        subject
        expect(response).to have_http_status(:unauthorized)
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
