# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharactersController, type: :controller do
  render_views

  let!(:character1) { create :character, name: "Lil Kay", universe: universe1 }
  let!(:character2) { create :character, name: "Osgood", universe: universe1 }
  let!(:character3) { create :character, name: "Scarlet", universe: universe2 }

  let(:universe1) { create :universe }
  let(:universe2) { create :universe }

  let(:collaborator) { create :user }

  before do
    universe1.collaborators << collaborator
    universe1.save!
  end

  describe "GET index" do
    context "when the user is authenticated as a user with access to the universe" do
      before do
        authenticate(collaborator)
        get(:index, format: :json, params: { universe_id: universe1.id })
      end

      RSpec.shared_examples "character JSON properties" do |property|
        it "returns the #{property.to_s.pluralize} for only characters belonging to the given universe" do
          expected_values = [
            character1.send(property),
            character2.send(property),
          ]
          received_values = json.collect do |character|
            character[property.to_s]
          end
          expect(received_values).to eq(expected_values)
        end
      end

      include_examples "character JSON properties", :id
      include_examples "character JSON properties", :name

      it "returns a success HTTP status code" do
        expect(response).to have_http_status(:success)
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the universe" do
      before do
        authenticate(create(:user))
        get(:index, format: :json, params: { universe_id: universe1.id })
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating this user can't interact with the universe" do
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe1.id} to interact with its characters.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      before do
        get(:index, format: :json, params: { universe_id: universe1.id })
      end

      it "returns a forbidden HTTP status code" do
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
