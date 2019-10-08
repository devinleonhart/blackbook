FactoryBot.define do
  factory :trait do
    sequence(:name) { |n| "Trait #{n}" }
  end
end
