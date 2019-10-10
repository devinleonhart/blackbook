# frozen_string_literal: true

json.id universe.id
json.name universe.name

json.owner do
  json.id universe.owner.id
  json.display_name universe.owner.display_name
end
json.collaborators universe.collaborators, :id, :display_name
json.characters universe.characters, :id, :name
json.locations universe.locations, :id, :name
