# frozen_string_literal: true

# == Schema Information
#
# Table name: character_traits
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  character_id :bigint           not null
#  trait_id     :bigint           not null
#
# Indexes
#
#  index_character_traits_on_character_id               (character_id)
#  index_character_traits_on_character_id_and_trait_id  (character_id,trait_id) UNIQUE
#  index_character_traits_on_trait_id                   (trait_id)
#
# Foreign Keys
#
#  fk_rails_...  (character_id => characters.id)
#  fk_rails_...  (trait_id => traits.id)
#

class CharacterTrait < ApplicationRecord
  validates :character, uniqueness: { scope: :trait_id }

  belongs_to :character, inverse_of: :character_traits
  belongs_to :trait, inverse_of: :character_traits

  delegate :universe, to: :character, allow_nil: true
end
