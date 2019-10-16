# frozen_string_literal: true

json.character_item do
  json.partial!(
    "api/v1/character_items/character_item",
    character_item: @character_item,
  )
end
