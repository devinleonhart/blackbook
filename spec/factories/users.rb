# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  display_name           :citext           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  admin                  :boolean          default(FALSE), not null
#
FactoryBot.define do
  factory :user do
    sequence(:display_name) { |n| "Test User #{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password123" }
    admin { false }
  end
end
