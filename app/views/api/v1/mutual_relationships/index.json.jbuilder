# frozen_string_literal: true

json.array! @mutual_relationships do |relationship|
  json.id relationship.mutual_relationship_id
  json.name relationship.name

  json.target_character do
    json.id relationship.target_character.id
    json.name relationship.target_character.name
  end
end
