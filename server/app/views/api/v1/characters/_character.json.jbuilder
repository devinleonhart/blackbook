# frozen_string_literal: true

json.id character.id
json.name character.name
json.description character.description

json.items do
  json.array!(character.character_items) do |character_item|
    json.id character_item.id
    json.name character_item.item.name
  end
end

json.traits do
  json.array!(character.character_traits) do |character_trait|
    json.id character_trait.id
    json.name character_trait.trait.name
  end
end
