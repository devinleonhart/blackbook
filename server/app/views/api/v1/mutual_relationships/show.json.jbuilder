# frozen_string_literal: true

json.mutual_relationship do
  json.partial!(
    "api/v1/mutual_relationships/mutual_relationship",
    mutual_relationship: @mutual_relationship,
  )
end
