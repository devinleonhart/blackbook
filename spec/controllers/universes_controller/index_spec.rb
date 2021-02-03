# frozen_string_literal: true

require "rails_helper"

RSpec.describe UniversesController, type: :controller do
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
    subject { get(:index, format: :json) }

    context "when the user is authenticated" do
      before { authenticate(owner1) }

      context "when all universes exist" do
        RSpec.shared_examples "universe JSON properties" do |property|
          it "returns all the universes' #{property.to_s.pluralize}" do
            subject
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

        it { is_expected.to have_http_status(:success) }

        it "returns the universes' owner information" do
          subject
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

        it "doesn't appear in the returned results" do
          subject
          universe_names = json.collect { |universe| universe["name"] }
          expect(universe_names).to match_array(["Milky Way", "Andromeda"])
        end
      end

      context "when a universe has been soft deleted" do
        before do
          universe3.discard!
        end

        it "doesn't appear in the returned results" do
          subject
          universe_names = json.collect { |universe| universe["name"] }
          expect(universe_names).to match_array(["Milky Way", "Andromeda"])
        end
      end
    end

    context "when the user isn't authenticated" do
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
