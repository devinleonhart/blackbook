# frozen_string_literal: true

# == Schema Information
#
# Table name: traits
#
#  id         :bigint           not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_traits_on_name  (name) UNIQUE
#

FactoryBot.define do
  factory :trait do
    sequence(:name) { |n| "Trait #{n}" }
  end
end
