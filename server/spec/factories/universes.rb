FactoryBot.define do
  factory :universe do
    sequence(:name) { |n| "Universe #{n}" }
    association :owner, factory: :user
  end
end
