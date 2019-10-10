# frozen_string_literal: true

# == Schema Information
#
# Table name: character_traits
#
#  id           :bigint           not null, primary key
#  character_id :bigint           not null
#  trait_id     :bigint           not null
#  value        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :character_trait do
    character
    association :trait, factory: :trait
    value { "value" }
  end
end
