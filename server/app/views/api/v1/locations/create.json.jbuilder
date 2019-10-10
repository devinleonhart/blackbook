# frozen_string_literal: true

json.location do
  json.partial! "api/v1/locations/location", location: @location
end
