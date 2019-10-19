# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::MutualRelationshipsController, type: :controller do
  render_views

  let(:mutual_relationship) do
    create(
      :mutual_relationship,
      character1: character1,
      character2: character2,
      forward_name: "Parent",
      reverse_name: "Child",
      character_universe: universe,
    )
  end
  let(:character1) { create :character, universe: universe }
  let(:character2) { create :character, universe: universe }

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "PUT/PATCH update" do
    context "when the user is authenticated as a user with access to the character's universe" do
      before do
        authenticate(collaborator)
      end

      context "when the mutual relationship exists" do
        context "when the parameters are valid" do
          let(:params) do
            {
              id: mutual_relationship.id,
              mutual_relationship: {
                originating_character_id: character1.id,
                forward_name: "Teacher",
                reverse_name: "Student",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:mutual_relationship_json) { json["mutual_relationship"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "updates the underlying Relationship models" do
            relationship_attributes =
              mutual_relationship
              .reload
              .relationships
              .map do |relationship|
                relationship.attributes.select do |key, _value|
                  [
                    "name",
                    "originating_character_id",
                    "target_character_id",
                  ].include? key
                end
              end

            expect(relationship_attributes).to match_array([
              {
                "name" => "Teacher",
                "originating_character_id" => character1.id,
                "target_character_id" => character2.id,
              },
              {
                "name" => "Student",
                "originating_character_id" => character2.id,
                "target_character_id" => character1.id,
              },
            ])
          end

          it "returns the MutualRelationship's ID" do
            expect(mutual_relationship_json["id"]).to eq(
              mutual_relationship.reload.id
            )
          end

          it "returns the MutualRelationship's updated forward name" do
            expect(mutual_relationship_json["forward_name"]).to eq("Teacher")
          end

          it "returns the MutualRelationship's updated reverse name" do
            expect(mutual_relationship_json["reverse_name"]).to eq("Student")
          end

          it "returns the MutualRelationship's original characters" do
            expect(mutual_relationship_json["character1"]).to eq(
              "id" => character1.id,
              "name" => character1.name,
            )
            expect(mutual_relationship_json["character2"]).to eq(
              "id" => character2.id,
              "name" => character2.name,
            )
          end
        end

        context "when the originating_character_id parameter is missing" do
          let(:params) do
            {
              id: mutual_relationship.id,
              mutual_relationship: {
                forward_name: "Teacher",
                reverse_name: "Student",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:mutual_relationship_json) { json["mutual_relationship"] }

          it "returns a bad request HTTP status code" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the mutual relationship" do
            relationship_names =
              mutual_relationship.reload.relationships.map(&:name)
            expect(relationship_names).to match_array(["Parent", "Child"])
          end

          it "returns an error message describing the missing character ID" do
            expect(json["errors"]).to eq([<<~ERROR_MESSAGE.squish])
              param is missing or the value is empty: originating_character_id
            ERROR_MESSAGE
          end
        end

        context "when the originating_character_id parameter is invalid" do
          let(:params) do
            {
              id: mutual_relationship.id,
              mutual_relationship: {
                originating_character_id: -1,
                forward_name: "Teacher",
                reverse_name: "Student",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:mutual_relationship_json) { json["mutual_relationship"] }

          it "returns a bad request HTTP status code" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the mutual relationship" do
            relationship_names =
              mutual_relationship.reload.relationships.map(&:name)
            expect(relationship_names).to match_array(["Parent", "Child"])
          end

          it "returns an error message describing the invalid character ID" do
            expect(json["errors"]).to eq([<<~ERROR_MESSAGE.squish])
              No character with ID -1 is associated with the relationship with
              ID #{mutual_relationship.id}.
            ERROR_MESSAGE
          end
        end

        context "when an attempt is made to change the mutual relationship's ID" do
          let(:params) do
            {
              id: mutual_relationship.id,
              mutual_relationship: {
                id: -1,
                originating_character_id: character1.id,
                forward_name: "Teacher",
                reverse_name: "Student",
              },
            }
          end

          before { put(:update, format: :json, params: params) }
          subject(:mutual_relationship_json) { json["mutual_relationship"] }

          it "returns a successful HTTP status code" do
            expect(response).to have_http_status(:success)
          end

          it "doesn't update the character trait's ID" do
            expect(mutual_relationship.reload.id).not_to eq(-1)
          end

          it "returns the character trait's original ID" do
            expect(mutual_relationship_json["id"]).to eq(mutual_relationship.id)
          end
        end

        context "when an attempt is made to change the relationship to duplicate an existing relationship" do
          let(:params) do
            {
              id: mutual_relationship.id,
              mutual_relationship: {
                originating_character_id: character1.id,
                forward_name: "Teacher",
                reverse_name: "Student",
              },
            }
          end

          before do
            create(
              :mutual_relationship,
              character1: character2,
              character2: character1,
              forward_name: "Student",
              reverse_name: "Teacher",
              character_universe: universe,
            )
            put(:update, format: :json, params: params)
          end

          it "returns a bad request status code" do
            expect(response).to have_http_status(:bad_request)
          end

          it "doesn't update the mutual relationship" do
            relationship_names =
              mutual_relationship.reload.relationships.map(&:name)
            expect(relationship_names).to match_array(["Parent", "Child"])
          end

          it "returns an error message describing the duplication" do
            expect(json["errors"]).to eq(["Name has already been taken"])
          end
        end
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      let(:params) do
        {
          id: mutual_relationship.id,
          mutual_relationship: { trait_name: "Tired" },
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
            #{universe.id} to interact with its relationships.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          id: mutual_relationship.id,
          mutual_relationship: { trait_name: "Tired" },
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
