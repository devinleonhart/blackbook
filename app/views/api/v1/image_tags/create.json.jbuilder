# frozen_string_literal: true

json.image_tag do
  json.partial! "api/v1/image_tags/image_tags", image_tag: @image_tag
end
