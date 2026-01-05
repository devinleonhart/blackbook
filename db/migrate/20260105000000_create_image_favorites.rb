# frozen_string_literal: true

class CreateImageFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :image_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end

    add_index :image_favorites, [:user_id, :image_id], unique: true
  end
end
