class DropLocationTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :facts, if_exists: true
    drop_table :locations, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
