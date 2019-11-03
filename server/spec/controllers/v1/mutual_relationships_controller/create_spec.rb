# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::MutualRelationshipsController, type: :controller do
  render_views

  let(:character1) { create :character, universe: universe }
  let(:character2) { create :character, universe: universe }

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "POST create" do
    context "when the user is authenticated as a user with access to the characters' parent universe" do
      before { authenticate(collaborator) }

      context "when the parameters are valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character1.id,
            mutual_relationship: {
              target_character_id: character2.id,
              forward_name: "Father",
              reverse_name: "Daughter",
            },
          }
        end

        before { post(:create, format: :json, params: params) }

        subject(:mutual_relationship) { MutualRelationship.first }
        subject(:mutual_relationship_json) { json["mutual_relationship"] }

        it "returns a successful HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "creates a new MutualRelationship model" do
          expect(mutual_relationship).not_to be_nil
        end

        it "creates a Relationship representing the forward direction of the mutual relationship" do
          relationship =
            Relationship
            .where(mutual_relationship: mutual_relationship)
            .where(originating_character: character1)
            .where(target_character: character2)
            .first
          expect(relationship.name).to eq("Father")
        end

        it "creates a Relationship representing the backward direction of the mutual relationship" do
          relationship =
            Relationship
            .where(mutual_relationship: mutual_relationship)
            .where(originating_character: character2)
            .where(target_character: character1)
            .first
          expect(relationship.name).to eq("Daughter")
        end

        it "returns the new MutualRelationship's ID" do
          expect(mutual_relationship_json["id"]).to eq(mutual_relationship.id)
        end
      end

      context "when an attempt is made to set the ID" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character1.id,
            mutual_relationship: {
              id: -1,
              target_character_id: character2.id,
              forward_name: "Father",
              reverse_name: "Daughter",
            },
          }
        end

        before { post(:create, format: :json, params: params) }

        subject(:mutual_relationship) { MutualRelationship.first }
        subject(:mutual_relationship_json) { json["mutual_relationship"] }

        it "returns a successful HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "creates a new MutualRelationship model with a new ID" do
          expect(mutual_relationship.id).not_to eq(-1)
        end

        it "returns a new MutualRelationship ID" do
          expect(mutual_relationship_json["id"]).to eq(mutual_relationship.id)
        end
      end

      context "when the character ID parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: -1,
            mutual_relationship: {
              target_character_id: character2.id,
              forward_name: "Father",
              reverse_name: "Daughter",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:mutual_relationship) { MutualRelationship.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the MutualRelationship" do
          expect(mutual_relationship).to be_nil
        end

        it "returns an error message for the invalid character ID" do
          expect(errors).to eq(["Originating character must exist"])
        end
      end

      context "when the forward name parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character1.id,
            mutual_relationship: {
              target_character_id: character2.id,
              forward_name: "",
              reverse_name: "Daughter",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:mutual_relationship) { MutualRelationship.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the MutualRelationship" do
          expect(mutual_relationship).to be_nil
        end

        it "returns an error message for the invalid relationship name" do
          expect(errors).to eq(["Name can't be blank"])
        end
      end

      context "when the other character ID parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character1.id,
            mutual_relationship: {
              target_character_id: -1,
              forward_name: "Father",
              reverse_name: "Daughter",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:mutual_relationship) { MutualRelationship.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the MutualRelationship" do
          expect(mutual_relationship).to be_nil
        end

        it "returns an error message for the invalid character ID" do
          expect(errors).to eq(["Target character must exist"])
        end
      end

      context "when the reverse name parameter isn't valid" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character1.id,
            mutual_relationship: {
              target_character_id: character2.id,
              forward_name: "Father",
              reverse_name: "",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:mutual_relationship) { MutualRelationship.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the MutualRelationship" do
          expect(mutual_relationship).to be_nil
        end

        it "returns an error message for the invalid relationship name" do
          expect(errors).to eq(["Name can't be blank"])
        end
      end

      context "when the two given characters are the same" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character1.id,
            mutual_relationship: {
              target_character_id: character1.id,
              forward_name: "Father",
              reverse_name: "Daughter",
            },
          }
        end

        before { post(:create, format: :json, params: params) }
        subject(:mutual_relationship) { MutualRelationship.first }
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the MutualRelationship" do
          expect(mutual_relationship).to be_nil
        end

        it "returns an error message for the duplicate characters" do
          expect(errors).to eq([<<~ERROR_MESSAGE.squish])
            A character can't have a relationship with itself.
          ERROR_MESSAGE
        end
      end

      context "when the the new relationship duplicates an existing relationship" do
        let(:params) do
          {
            universe_id: universe.id,
            character_id: character1.id,
            mutual_relationship: {
              target_character_id: character2.id,
              forward_name: "Father",
              reverse_name: "Daughter",
            },
          }
        end

        before do
          create(
            :mutual_relationship,
            character1: character1,
            character2: character2,
            forward_name: "Dad",
            reverse_name: "Daughter",
            character_universe: universe,
          )
          post(:create, format: :json, params: params)
        end
        subject(:errors) { json["errors"] }

        it "returns a Bad Request status" do
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the new MutualRelationship" do
          expect(MutualRelationship.count).to eq(1)
        end

        it "returns an error message about the duplicate relationship" do
          expect(errors).to eq(["Name has already been taken"])
        end
      end

      context "when the given character doesn't belong to the given universe" do
        let(:non_universe_character) { create :character }

        let(:params) do
          {
            universe_id: universe.id,
            character_id: non_universe_character.id,
            mutual_relationship: {
              target_character_id: character2.id,
              forward_name: "Father",
              reverse_name: "Daughter",
            },
          }
        end

        subject { post(:create, format: :json, params: params) }

        it "returns a Bad Request status" do
          subject
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create any relationships" do
          expect { subject }.not_to change { MutualRelationship.count }.from(0)
          expect { subject }.not_to change { Relationship.count }.from(0)
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

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      let(:params) do
        {
          universe_id: universe.id,
          character_id: character1.id,
          mutual_relationship: {
            target_character_id: character2.id,
            forward_name: "Father",
            reverse_name: "Daughter",
          },
        }
      end

      before do
        authenticate(create(:user))
        post(:create, format: :json, params: params)
      end

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't create a new MutualRelationship" do
        expect(MutualRelationship.count).to eq(0)
      end

      it "returns an error message informing the user they don't have access" do
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
        {
          universe_id: universe.id,
          character_id: character1.id,
          mutual_relationship: {
            target_character_id: character2.id,
            forward_name: "Father",
            reverse_name: "Daughter",
          },
        }
      end

      before { post(:create, format: :json, params: params) }

      it "returns an unauthorized HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't create a new MutualRelationship" do
        expect(MutualRelationship.count).to eq(0)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
