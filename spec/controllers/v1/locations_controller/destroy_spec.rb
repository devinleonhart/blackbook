# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let!(:location) { create :location, universe: universe }

  let(:universe) { create :universe, owner: owner }
  let(:owner) { create :user }
  let(:collaborator) { create :user }
  let(:not_owner) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "DELETE destroy" do
    subject { delete(:destroy, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the parent universe" do
      before { authenticate(collaborator) }

      context "when the location exists" do
        let(:params) { { id: location.id } }

        it { is_expected.to have_http_status(:success) }

        it "deletes the location" do
          expect { subject }.to change { Location.count }.by(-1)
        end
      end

      context "when the location doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message informing the user the resource doesn't exist" do
          subject
          expect(json["errors"]).to eq(["No location with ID -1 exists."])
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the parent universe" do
      before { authenticate(not_owner) }

      let(:params) { { id: location.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't delete the Location" do
        expect { subject }.not_to change { Location.count }
      end

      it "returns an error message informing the user they don't have access" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its locations.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: location.id } }

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't delete the Location" do
        expect { subject }.not_to change { Location.count }
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
