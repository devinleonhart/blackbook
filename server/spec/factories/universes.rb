# frozen_string_literal: true

# == Schema Information
#
# Table name: universes
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  owner_id     :bigint           not null
#  discarded_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :universe do
    sequence(:name) { |n| "Universe #{n}" }
    association :owner, factory: :user
  end
end
