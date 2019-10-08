# frozen_string_literal: true

json.array! @universes do |universe|
  json.id universe.id
  json.name universe.name

  json.owner do
    json.id universe.owner.id
    json.name universe.owner.name
  end
end
