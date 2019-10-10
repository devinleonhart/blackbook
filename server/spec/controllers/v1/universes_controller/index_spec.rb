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

  describe "GET index" do
    context "when all universes are available" do
      before { get(:index, format: :json) }

      RSpec.shared_examples "universe JSON properties" do |property|
        it "returns all the universes' #{property.to_s.pluralize}" do
          expected_values = [
            universe1.send(property),
            universe2.send(property),
            universe3.send(property),
          ]
          received_values = json.collect { |universe| universe[property.to_s] }
          expect(received_values).to eq(expected_values)
        end
      end

      include_examples "universe JSON properties", :id
      include_examples "universe JSON properties", :name

      it "returns the universes' owner information" do
        owner_information = json.collect { |universe| universe["owner"] }
        expect(owner_information).to eq([
          {
            "id" => owner1.id,
            "name" => owner1.name,
          },
          {
            "id" => owner2.id,
            "name" => owner2.name,
          },
          {
            "id" => owner3.id,
            "name" => owner3.name,
          },
        ])
      end
    end

    context "when a universe has been soft deleted" do
      before do
        universe3.discard!
      end

      before { get(:index, format: :json) }

      it "doesn't appear in the returned results" do
        universe_names = json.collect { |universe| universe["name"] }
        expect(universe_names).to eq(["Milky Way", "Andromeda"])
      end
    end
  end
end
