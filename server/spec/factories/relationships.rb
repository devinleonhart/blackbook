# frozen_string_literal: true

# == Schema Information
#
# Table name: relationships
#
#  id                       :bigint           not null, primary key
#  mutual_relationship_id   :bigint           not null
#  originating_character_id :bigint           not null
#  target_character_id      :bigint           not null
#  name                     :citext           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

FactoryBot.define do
  factory :relationship do
    mutual_relationship
    association :originating_character, factory: :character
    association :target_character, factory: :character
    sequence(:name) { |n| "Relationship #{n}" }
  end
end
