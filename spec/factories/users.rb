# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:display_name) { |n| "Test User #{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password123" }
    admin { false }
  end
end
