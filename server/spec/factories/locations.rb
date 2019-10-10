# frozen_string_literal: true

# == Schema Information
#
# Table name: locations
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :string           not null
#  universe_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    description { "description" }
    universe
  end
end
