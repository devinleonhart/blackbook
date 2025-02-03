FactoryBot.define do
  factory :universe do
    name { "Test Universe" }
    association :owner, factory: :user
  end
end
