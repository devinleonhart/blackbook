# frozen_string_literal: true

class AddIndexToUniverse < ActiveRecord::Migration[6.1]
  def change
    add_index :universes, [:name, :owner_id], unique: true
  end
end
