# frozen_string_literal: true

json.id image_tag.id
json.character do
  json.id image_tag.character.id
  json.name image_tag.character.name
end
json.image do
  json.id image_tag.image.id
  json.url url_for(image_tag.image.image_file)
end
