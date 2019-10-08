FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    description { "description" }
    universe
  end
end
