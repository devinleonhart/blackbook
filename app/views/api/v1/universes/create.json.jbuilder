# frozen_string_literal: true

json.universe do
  json.partial! "api/v1/universes/universe", universe: @universe
end
