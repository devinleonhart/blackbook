FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    password { "password" }

    trait :with_blank_password do
      password { "" }
    end
  end
end
