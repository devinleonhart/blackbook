# frozen_string_literal: true

FactoryBot.define do
  factory :character_trait do
    character
    association :trait, factory: :trait
    value { "value" }
  end
end
