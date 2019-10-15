# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UniversesController, type: :controller do
  render_views

  let(:owner1) { create :user }
  let(:owner2) { create :user }
  let(:owner3) { create :user }

  let!(:universe1) { create :universe, name: "Milky Way", owner: owner1 }
  let!(:universe2) { create :universe, name: "Andromeda", owner: owner2 }
  let!(:universe3) { create :universe, name: "NGC 1300", owner: owner3 }

  before do
    universe2.collaborators << owner1
    universe2.collaborators << owner3
    universe2.save!
    universe3.collaborators << owner1
    universe3.save!
  end

  describe "GET index" do
    context "when the user is authenticated" do
      before { authenticate(owner1) }

      context "when all universes exist" do
        before { get(:index, format: :json) }

        RSpec.shared_examples "universe JSON properties" do |property|
          it "returns all the universes' #{property.to_s.pluralize}" do
            expected_values = [
              universe1.send(property),
              universe2.send(property),
              universe3.send(property),
            ]
            received_values = json.collect do |universe|
              universe[property.to_s]
            end
            expect(received_values).to match_array(expected_values)
          end
        end

        include_examples "universe JSON properties", :id
        include_examples "universe JSON properties", :name

        it "returns a success HTTP status code" do
          expect(response).to have_http_status(:success)
        end

        it "returns the universes' owner information" do
          owner_information = json.collect { |universe| universe["owner"] }
          expect(owner_information).to match_array([
            {
              "id" => owner1.id,
              "display_name" => owner1.display_name,
            },
            {
              "id" => owner2.id,
              "display_name" => owner2.display_name,
            },
            {
              "id" => owner3.id,
              "display_name" => owner3.display_name,
            },
          ])
        end
      end

      context "when a universe isn't associated with the user via ownership or collaboration" do
        before do
          universe3.collaborators = []
          universe3.save!
        end

        before { get(:index, format: :json) }

        it "doesn't appear in the returned results" do
          universe_names = json.collect { |universe| universe["name"] }
          expect(universe_names).to match_array(["Milky Way", "Andromeda"])
        end
      end

      context "when a universe has been soft deleted" do
        before do
          universe3.discard!
        end

        before { get(:index, format: :json) }

        it "doesn't appear in the returned results" do
          universe_names = json.collect { |universe| universe["name"] }
          expect(universe_names).to match_array(["Milky Way", "Andromeda"])
        end
      end
    end

    context "when the user isn't authenticated" do
      before { get(:index, format: :json) }

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
