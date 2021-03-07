# frozen_string_literal: true

class AddUniverseAvatarToImage < ActiveRecord::Migration[6.1]
  change_table :images do |t|
    t.boolean :universe_avatar
  end
end
