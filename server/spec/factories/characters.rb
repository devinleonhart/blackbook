# frozen_string_literal: true

FactoryBot.define do
  factory :character do
    sequence(:name) { |n| "Character #{n}" }
    description { 'description' }
    universe
  end
end
