# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let!(:universe) { create :universe, owner: owner }

  let(:owner) { create :user }
  let(:collaborator) { create :user }
  let(:not_owner) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "DELETE destroy" do
    subject { delete(:destroy, format: :json, params: params) }

    context "when the user is authenticated as the universe's owner" do
      before { authenticate(owner) }

      context "when the universe is available" do
        let(:params) { { id: universe.id } }

        it { is_expected.to have_http_status(:success) }

        it "soft deletes the universe" do
          subject
          expect(universe.reload.discarded?).to be(true)
        end
      end

      context "when the universe has already been deleted" do
        before do
          universe.discard!
        end

        let(:params) { { id: universe.id } }

        it { is_expected.to have_http_status(:not_found) }

        it "is idempotent" do
          expect(universe.reload.discarded?).to be(true)
        end
      end

      context "when the universe doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }

        it "returns an error message informing the user the resource doesn't exist" do
          subject
          expect(json["errors"]).to eq(["No universe with ID -1 exists."])
        end
      end
    end

    context "when the user is signed in as a collaborator" do
      before do
        authenticate(collaborator)
      end

      let(:params) { { id: universe.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't destroy the universe" do
        expect { subject }.not_to change { Universe.count }
      end
    end

    context "when the user is signed in as a user who isn't the universe's owner" do
      before do
        authenticate(not_owner)
      end

      let(:params) { { id: universe.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't destroy the universe" do
        expect { subject }.not_to change { Universe.count }
      end

      it "doesn't soft delete the universe" do
        expect { subject }.not_to change { Universe.kept.count }
      end

      it "returns an error message indicating only the owner can delete a universe" do
        subject
        expect(json["errors"]).to(
          eq(["A universe can only be deleted by its owner."])
        )
      end
    end

    context "when the user is signed in as a user who isn't the universe's owner" do
      before do
        authenticate(not_owner)
      end

      let(:params) { { id: universe.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't destroy the universe" do
        expect { subject }.not_to change { Universe.count }
      end

      it "doesn't soft delete the universe" do
        expect { subject }.not_to change { Universe.kept.count }
      end

      it "returns an error message indicating only the owner can delete a universe" do
        subject
        expect(json["errors"]).to(
          eq(["A universe can only be deleted by its owner."])
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: universe.id } }

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't destroy the universe" do
        expect { subject }.not_to change { Universe.count }
      end

      it "doesn't soft delete the universe" do
        expect { subject }.not_to change { Universe.kept.count }
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
