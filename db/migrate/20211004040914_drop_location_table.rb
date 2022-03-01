class DropLocationTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :facts
    drop_table :locations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
