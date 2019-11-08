# frozen_string_literal: true

json.id user.id
json.display_name user.display_name
json.avatar_url user.avatar.attached? ? url_for(user.avatar) : nil
