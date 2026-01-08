# frozen_string_literal: true

class AddFavoriteToImages < ActiveRecord::Migration[7.0]
  def change
    add_column :images, :favorite, :boolean, default: false, null: false
  end
end
