# frozen_string_literal: true

class RemoveAvatar < ActiveRecord::Migration[6.1]
  def up
    remove_column :images, :avatar
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
