FactoryBot.define do
  factory :user do
    display_name { "Test User" }
    email { "test@example.com" }
    password { "password123" }
    admin { false }
  end
end
