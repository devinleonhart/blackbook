# frozen_string_literal: true

json.array!(
  @character_traits,
  partial: "api/v1/character_traits/character_trait",
  as: :character_trait,
)
