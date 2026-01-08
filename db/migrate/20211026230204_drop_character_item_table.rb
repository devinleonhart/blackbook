# frozen_string_literal: true

class DropCharacterItemTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :character_items
    drop_table :items
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
