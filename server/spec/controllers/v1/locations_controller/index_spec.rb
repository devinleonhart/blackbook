# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let!(:location1) { create :location, name: "Milky Way", universe: universe1 }
  let!(:location2) { create :location, name: "Andromeda", universe: universe1 }
  let!(:location3) { create :location, name: "NGC 1300", universe: universe2 }

  let(:universe1) { create :universe }
  let(:universe2) { create :universe }

  let(:collaborator) { create :user }

  before do
    universe1.collaborators << collaborator
    universe1.save!
  end

  describe "GET index" do
    subject { get(:index, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      let(:params) { { universe_id: universe1.id } }

      RSpec.shared_examples "location JSON properties" do |property|
        it "returns the #{property.to_s.pluralize} for only locations belonging to the given universe" do
          subject
          expected_values = [
            location1.send(property),
            location2.send(property),
          ]
          received_values = json.collect { |location| location[property.to_s] }
          expect(received_values).to eq(expected_values)
        end
      end

      include_examples "location JSON properties", :id
      include_examples "location JSON properties", :name

      it { is_expected.to have_http_status(:success) }
    end

    context "when the user is authenticated as a user who doesn't have access to the universe" do
      before { authenticate(create(:user)) }

      let(:params) { { universe_id: universe1.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating this user can't interact with the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe1.id} to interact with its locations.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { universe_id: universe1.id } }

      it { is_expected.to have_http_status(:unauthorized) }

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
