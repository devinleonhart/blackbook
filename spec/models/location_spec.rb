# frozen_string_literal: true

# == Schema Information
#
# Table name: locations
#
#  id          :bigint           not null, primary key
#  name        :citext           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :bigint           not null
#
# Indexes
#
#  index_locations_on_name_and_universe_id  (name,universe_id) UNIQUE
#  index_locations_on_universe_id           (universe_id)
#
# Foreign Keys
#
#  fk_rails_...  (universe_id => universes.id)
#

require "rails_helper"

RSpec.describe Location, type: :model do
  before do
    @location1 = FactoryBot.create(:location, { name: "Arboria"} )
  end

  it "should not allow an empty location name" do
    @location1.name = ""
    expect(@location1).to be_invalid
  end

  it "should not allow a nil location name" do
    @location1.name = nil
    expect(@location1).to be_invalid
  end
end
