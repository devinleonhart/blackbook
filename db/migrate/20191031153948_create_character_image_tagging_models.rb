# frozen_string_literal: true

class CreateCharacterImageTaggingModels < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.text :caption, null: false, default: ""

      t.timestamps
    end

    create_table :image_tags do |t|
      t.references :character, null: false
      t.references :image, null: false

      t.timestamps
    end
    add_index :image_tags, [:character_id, :image_id], unique: true
  end
end
