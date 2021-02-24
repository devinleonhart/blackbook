# frozen_string_literal: true

class CharacterImageComponent < ViewComponent::Base
  def initialize(character:, images:)
    @character = character
    @images = images
    @character_item = CharacterItem.new()
  end
end
