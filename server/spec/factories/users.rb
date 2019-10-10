# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    password { "password" }

    trait :with_blank_password do
      password { "" }
    end
  end
end
