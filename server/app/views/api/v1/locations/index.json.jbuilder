# frozen_string_literal: true

json.array! @locations do |location|
  json.id location.id
  json.name location.name
end
