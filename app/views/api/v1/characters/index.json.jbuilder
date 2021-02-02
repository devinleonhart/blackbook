# frozen_string_literal: true

json.page @page
json.page_size @page_size
json.total_pages @total_pages
json.characters do
  json.array! @characters do |character|
    json.id character.id
    json.name character.name
  end
end
