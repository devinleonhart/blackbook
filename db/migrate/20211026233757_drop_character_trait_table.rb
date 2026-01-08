# frozen_string_literal: true

class DropCharacterTraitTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :character_traits
    drop_table :traits
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
