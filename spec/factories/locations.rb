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

FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    universe
  end
end
