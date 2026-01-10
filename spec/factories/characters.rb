# frozen_string_literal: true

FactoryBot.define do
  factory :character do
    sequence(:name) { |n| "Character #{n}" }
    association :universe
  end
end
