# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  description  :string           not null
#  universe_id  :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

FactoryBot.define do
  factory :character do
    sequence(:name) { |n| "Character #{n}" }
    description { "description" }
    universe
  end
end
