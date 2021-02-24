# frozen_string_literal: true

class CharacterItemComponent < ViewComponent::Base
  def initialize(character:)
    @character = character
    @character_item = CharacterItem.new()
  end
end
