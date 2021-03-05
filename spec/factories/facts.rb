# frozen_string_literal: true

FactoryBot.define do
  factory :fact do
    sequence(:fact_type) { |n| "Type #{n}" }
    sequence(:content) { |n| "Fact #{n}" }
  end
end
