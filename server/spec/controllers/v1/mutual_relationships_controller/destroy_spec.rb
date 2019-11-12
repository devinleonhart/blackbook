# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::MutualRelationshipsController, type: :controller do
  render_views

  let!(:mutual_relationship) do
    create :mutual_relationship, character_universe: universe
  end

  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "DELETE destroy" do
    subject { delete(:destroy, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the MutualRelationship exists" do
        let(:params) { { id: mutual_relationship.id } }

        it { is_expected.to have_http_status(:success) }

        it "deletes the MutualRelationship" do
          expect { subject }.to change { MutualRelationship.count }.by(-1)
        end

        it "deletes the attached Relationships" do
          expect { subject }.to change { Relationship.count }.by(-2)
        end
      end

      context "when the MutualRelationship doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message informing the user the resource doesn't exist" do
          subject
          expect(json["errors"]).to eq(
            ["No MutualRelationship with ID -1 exists."]
          )
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      before { authenticate(create(:user)) }

      let(:params) { { id: mutual_relationship.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't delete the MutualRelationship" do
        expect { subject }.not_to change { MutualRelationship.count }
      end

      it "doesn't delete the attached Relationships" do
        expect { subject }.not_to change { Relationship.count }
      end

      it "returns an error message informing the user they don't have access" do
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
      let(:params) { { id: mutual_relationship.id } }

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't delete the MutualRelationship" do
        expect { subject }.not_to change { MutualRelationship.count }
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
