# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id           :bigint           not null, primary key
#  name         :citext           not null
#  universe_id  :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#
FactoryBot.define do
  factory :character do
    sequence(:name) { |n| "Character #{n}" }
    association :universe
  end
end
