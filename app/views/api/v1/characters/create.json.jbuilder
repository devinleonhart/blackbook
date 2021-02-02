# frozen_string_literal: true

json.character do
  json.partial! "api/v1/characters/character", character: @character
end
