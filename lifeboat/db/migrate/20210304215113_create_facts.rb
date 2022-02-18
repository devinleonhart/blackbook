# frozen_string_literal: true

class CreateFacts < ActiveRecord::Migration[6.1]
  def change
    create_table :facts do |t|
      t.text :content, null: false
      t.string :fact_type, null: false
      t.references :character, foreign_key: true, index: true
      t.references :location, foreign_key: true, index: true

      t.timestamps
    end
  end
end
