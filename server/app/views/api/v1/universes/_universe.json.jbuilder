# frozen_string_literal: true

json.id universe.id
json.name universe.name

json.owner do
  json.id universe.owner.id
  json.name universe.owner.name
end
json.collaborators universe.collaborators, :id, :name
json.characters universe.characters, :id, :name
json.locations universe.locations, :id, :name
