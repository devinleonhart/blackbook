# frozen_string_literal: true

json.character_trait do
  json.partial!(
    "api/v1/character_traits/character_trait",
    character_trait: @character_trait,
  )
end
