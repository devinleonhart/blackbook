# frozen_string_literal: true

class CreateCharacterTags < ActiveRecord::Migration[7.0]
  def change
    create_table :character_tags do |t|
      t.string :name, null: false
      t.references :character, null: false, foreign_key: true

      t.timestamps
    end

    add_index :character_tags, [:character_id, :name], unique: true
    add_index :character_tags, :name
  end
end
