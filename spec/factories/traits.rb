# frozen_string_literal: true

# == Schema Information
#
# Table name: traits
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#
# Indexes
#
#  index_traits_on_character_id           (character_id)
#  index_traits_on_character_id_and_name  (character_id,name) UNIQUE
#  index_traits_on_name                   (name)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
#
FactoryBot.define do
  factory :trait do
    character
    sequence(:name) { |n| "tag#{n}" }
  end
end
