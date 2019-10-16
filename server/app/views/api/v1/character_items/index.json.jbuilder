# frozen_string_literal: true

json.array!(
  @character_items,
  partial: "api/v1/character_items/character_item",
  as: :character_item,
)
