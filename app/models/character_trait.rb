# frozen_string_literal: true

# == Schema Information
#
# Table name: character_traits
#
#  id           :bigint           not null, primary key
#  character_id :bigint           not null
#  trait_id     :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CharacterTrait < ApplicationRecord
  validates :character, uniqueness: { scope: :trait_id }

  belongs_to :character, inverse_of: :character_traits
  belongs_to :trait, inverse_of: :character_traits

  delegate :universe, to: :character, allow_nil: true
end
