# frozen_string_literal: true

class RemoveFavoriteFromImages < ActiveRecord::Migration[7.0]
  def change
    remove_column :images, :favorite, :boolean
  end
end
