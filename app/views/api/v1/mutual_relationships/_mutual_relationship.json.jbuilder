# frozen_string_literal: true

json.id mutual_relationship.id
json.forward_name mutual_relationship.relationships.first.name
json.reverse_name mutual_relationship.relationships.last.name
json.character1 do
  json.id mutual_relationship.characters.first.id
  json.name mutual_relationship.characters.first.name
end
json.character2 do
  json.id mutual_relationship.characters.last.id
  json.name mutual_relationship.characters.last.name
end
