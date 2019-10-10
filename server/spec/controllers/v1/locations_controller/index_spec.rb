# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :controller do
  render_views

  let(:universe1) { create :universe }
  let(:universe2) { create :universe }

  let!(:location1) { create :location, name: "Milky Way", universe: universe1 }
  let!(:location2) { create :location, name: "Andromeda", universe: universe1 }
  let!(:location3) { create :location, name: "NGC 1300", universe: universe2 }

  describe "GET index" do
    before do
      get(:index, format: :json, params: { universe_id: universe1.id })
    end

    RSpec.shared_examples "location JSON properties" do |property|
      it "returns the #{property.to_s.pluralize} for only locations belonging to the given universe" do
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
  end
end
