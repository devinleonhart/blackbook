# frozen_string_literal: true

json.id location.id
json.name location.name
json.description location.description

json.universe do
  json.id location.universe.id
  json.name location.universe.name
end
