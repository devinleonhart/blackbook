# frozen_string_literal: true

json.id image.id
json.caption image.caption
json.image_url url_for(image.image_file)
json.characters do
  characters_visible_to_user =
    image
    .characters
    .filter do |character|
      character.universe.visible_to_user? current_api_v1_user
    end
  json.array!(characters_visible_to_user) do |character|
    json.id character.id
    json.name character.name
  end
end
