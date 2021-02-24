# frozen_string_literal: true

class CharacterTraitComponent < ViewComponent::Base
  def initialize(character:)
    @character = character
    @character_trait = CharacterTrait.new()
  end
end
